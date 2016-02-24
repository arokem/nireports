#!/usr/bin/env python
# -*- coding: utf-8 -*-
# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:
# pylint: disable=no-member
#
# @Author: oesteban
# @Date:   2016-02-23 19:25:39
# @Email:  code@oscaresteban.es
# @Last Modified by:   oesteban
# @Last Modified time: 2016-02-24 14:34:49
"""
Computation of the quality assessment measures on functional MRI
----------------------------------------------------------------


"""
import os.path as op
import numpy as np
import nibabel as nb
from nitime import algorithms as nta
import scipy


def gsr(epi_data, mask, direction="y", ref_file=None, out_file=None):
    """
    Computes the :abr:`GSR (ghost to signal ratio)` [Giannelli2010]_. The
    procedure is as follows:

      #. Create a Nyquist ghost mask by circle-shifting the original mask by
        :math:`N/2`.

      #. Rotate by :math:`N/2`

      #. Remove the intersection with the original mask

      #. Generate a non-ghost background

      #. Calculate the :abr:`GSR (ghost to signal ratio)`



    .. warning ::

      This should be used with EPI images for which the phase
      encoding direction is known.

    Parameters
    ----------
    epi_file: str
        path to epi file
    mask_file: str
        path to brain mask
    direction: str
        the direction of phase encoding (x, y, all)

    Returns
    -------
    gsr: float
        ghost to signal ratio


    .. [Giannelli2010] Giannelli et al. *Characterization of Nyquist ghost in
      EPI-fMRI acquisition sequences implemented on two clinical 1.5 T MR scanner
      systems: effect of readout bandwidth and echo spacing*. J App Clin Med Phy,
      11(4). 2010.
      doi:`10.1120/jacmp.v11i4.3237 <http://dx.doi.org/10.1120/jacmp.v11i4.3237>`.


    """

    direction = direction.lower()
    if direction[-1] not in ['x', 'y', 'all']:
        raise Exception("Unknown direction %s, should be one of x, -x, y, -y, all"
                        % direction)

    if direction == 'all':
        result = []
        for newdir in ['x', 'y']:
            ofile = None
            if out_file is not None:
                fname, ext = op.splitext(ofile)
                if ext == '.gz':
                    fname, ext2 = op.splitext(fname)
                    ext = ext2 + ext
                ofile = '%s_%s%s' % (fname, newdir, ext)
            result += [gsr(epi_data, mask, newdir,
                           ref_file=ref_file, out_file=ofile)]
        return result

    # Step 1
    n2_mask = np.zeros_like(mask)

    # Step 2
    if direction == "x":
        n2lim = np.floor(mask.shape[0]/2)
        n2_mask[:n2lim, :, :] = mask[n2lim:(n2lim*2), :, :]
        n2_mask[n2lim:(n2lim*2), :, :] = mask[:n2lim, :, :]
    elif direction == "y":
        n2lim = np.floor(mask.shape[1]/2)
        n2_mask[:, :n2lim, :] = mask[:, n2lim:(n2lim*2), :]
        n2_mask[:, n2lim:(n2lim*2), :] = mask[:, :n2lim, :]
    elif direction == "z":
        n2lim = np.floor(mask.shape[2]/2)
        n2_mask[:, :, :n2lim] = mask[:, :, n2lim:(n2lim*2)]
        n2_mask[:, :, n2lim:(n2lim*2)] = mask[:, :, :n2lim]

    # Step 3
    n2_mask = n2_mask * (1-mask)

    # Step 4: non-ghost background region is labeled as 2
    n2_mask = n2_mask + 2 * (1 - n2_mask - mask)

    # Save mask
    if ref_file is not None and out_file is not None:
        ref = nb.load(ref_file)
        out = nb.Nifti1Image(n2_mask, ref.get_affine(), ref.get_header())
        out.to_filename(out_file)

    # Step 5: signal is the entire foreground image
    ghost = epi_data[n2_mask == 1].mean() - epi_data[n2_mask == 2].mean()
    signal = epi_data[n2_mask == 0].mean()
    return ghost/signal


def dvars(func, mask, output_all=False, out_file=None):
    """
    Compute the mean :abbr:`DVARS (D referring to temporal derivative of
    timecourses, VARS referring to RMS variance over voxels)` [Power2012]_


    .. [Power2012] Poweret al., *Spurious but systematic correlations in functional
      connectivity MRI networks arise from subject motion*, NeuroImage 59(3):2142-2154,
      2012, doi:`10.1016/j.neuroimage.2011.10.018
      <http://dx.doi.org/10.1016/j.neuroimage.2011.10.018>`.


    """
    if len(func.shape) != 4:
        raise RuntimeError(
            "Input fMRI dataset should be 4-dimensional" % func)

    # Remove zero-variance voxels across time axis
    mfunc, tv_mask = zero_variance(func, mask)

    # Robust standard deviation
    func_sd = (np.percentile(mfunc, 75) - np.percentile(mfunc, 25)) / 1.349

    # AR1
    func_ar_a0 = ar_nitime(mfunc, tv_mask, 0)

    # Predicted standard deviation of temporal derivative
    func_sd_pd = np.sqrt(2 * (1 - func_ar_a0)) * func_sd
    diff_sd_mean = func_sd_pd.mean()

    # Compute temporal difference time series
    func_deriv = np.diff(mfunc, axis=1)

    # DVARS (no standardization)
    # TODO: Why are we not ^2 this & getting the sqrt?
    dvars_plain = func_deriv.std(1, ddof=1)
    # standardization
    dvars_stdz = dvars_plain/diff_sd_mean
    # voxelwise standardization
    diff_vx_stdz = func_deriv/func_sd_pd
    dvars_vx_stdz = diff_vx_stdz.std(1, ddof=1)

    if output_all:
        gendvars = np.vstack((dvars_stdz, dvars_plain, dvars_vx_stdz))
    else:
        gendvars = dvars_stdz.reshape(len(dvars_stdz), 1)

    if out_file is not None:
        np.savetxt(out_file, gendvars, fmt='%.12f')

    return gendvars


def ar_nitime(mfunc, mask, order=1):
    """
    Adapts the computation of the :abbr:`AR (auto-regressive)` filtering
    from nitime to the fMRI signal.

    """
    mfunc = mfunc.reshape((-1, mfunc.shape[-1]))
    mask = np.array([mask.reshape(-1)] * mfunc.shape[-1]).T
    mfunc -= mfunc.mean(axis=1)[..., np.newaxis]

    ak_coeffs = []
    for tpt in mfunc.T:
        ak_coeffs.append(nta.AR_est_YW(tpt, order, None))
    return np.array(ak_coeffs)[:, 0].T


def fd_jenkinson(in_file, rmax=80., out_file=None):
    """
    Compute the :abbr:`FD (framewise displacement)` [Jenkinson2002]_
    on a 4D dataset, after ```3dvolreg``` has been executed
    (generally a file named ```*.affmat12.1D```).

    Parameters
    ----------

    in_file: str
        path to epi file

    rmax: float
        The default radius (as in FSL) of a sphere represents the brain

    out_file: str
        output file with the FD


    Returns
    -------
    out_file: string
        output file with the FD

    mean_fd: float
        average FD along the time series


    .. note ::

      :code:`infile` should have one 3dvolreg affine matrix in one row -
      NOT the motion parameters


    .. note ::

      Adapted from
      https://github.com/oesteban/quality-assessment-protocol/blob/enh/SmartQCWorkflow/qap/temporal_qc.py#L16


    .. [Jenkinson2002] Jenkinson et al., *Improved Optimisation for the Robust and
      Accurate Linear Registration and Motion Correction of Brain Images.
      NeuroImage, 17(2), 825-841, 2002.
      doi:`10.1006/nimg.2002.1132 <http://dx.doi.org/10.1006/nimg.2002.1132>`.

    """

    import sys
    import math

    if out_file is None:
        fname, ext = op.splitext(op.basename(in_file))
        out_file = op.abspath('%s_fdfile%s' % (fname, ext))

    # if in_file (coordinate_transformation) is actually the rel_mean output
    # of the MCFLIRT command, forward that file
    if 'rel.rms' in in_file:
        return in_file

    pm_ = np.genfromtxt(in_file)
    original_shape = pm_.shape
    pm = np.zeros((pm_.shape[0], pm_.shape[1] + 4))
    pm[:, :original_shape[1]] = pm_
    pm[:, original_shape[1]:] = [0.0, 0.0, 0.0, 1.0]

    # rigid body transformation matrix
    T_rb_prev = np.matrix(np.eye(4))

    flag = 0
    X = [0]  # First timepoint
    for i in range(0, pm.shape[0]):
        # making use of the fact that the order of aff12 matrix is "row-by-row"
        T_rb = np.matrix(pm[i].reshape(4, 4))

        if flag == 0:
            flag = 1
        else:
            M = np.dot(T_rb, T_rb_prev.I) - np.eye(4)
            A = M[0:3, 0:3]
            b = M[0:3, 3]

            FD_J = math.sqrt(
                (rmax * rmax / 5) * np.trace(np.dot(A.T, A)) + np.dot(b.T, b))
            X.append(FD_J)

        T_rb_prev = T_rb
    np.savetxt(out_file, X)
    return out_file


def gcor(in_file, mask):
    """
    Compute the :abbr:`GCOR (global correlation)`.

    Parameters
    ----------

    in_file: numpy.ndarray
        input fMRI dataset, after motion correction

    mask: numpy.ndarray
        headmask


    Returns
    -------
    gcor: float
        the computed GCOR value

    """
    # Remove zero-variance voxels across time axis
    tvariance, tv_mask = zero_variance(in_file, mask)
    zscores = scipy.stats.mstats.zscore(tvariance[tv_mask > 0], axis=1)
    avg_ts = zscores.mean(axis=0)
    return avg_ts.transpose().dot(avg_ts) / len(avg_ts)

def zero_variance(func, mask):
    """
    Mask out voxels with zero variance across t-axis

    """
    func *= mask[..., np.newaxis]
    tvariance = func.var(axis=3)
    tv_mask = np.zeros_like(tvariance)
    tv_mask[tvariance > 0] = 1
    func *= tv_mask[..., np.newaxis]
    return func, tv_mask
