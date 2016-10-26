#!/usr/bin/env python
# -*- coding: utf-8 -*-
# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:
""" mriqc nipype interfaces """
from __future__ import print_function
from __future__ import division
from __future__ import absolute_import
from __future__ import unicode_literals

from mriqc.interfaces.anatomical import ArtifactMask
from mriqc.interfaces.qc import StructuralQC, FunctionalQC
from mriqc.interfaces.bids import ReadSidecarJSON
