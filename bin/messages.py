ABIDE_SUBJECT_FETCHED = "Successfully processed subject {subject_id} from site {site_name}"
ABIDE_TEMPORAL_WARNING = "WARNING: Error deleting temporal files: {message}"
DFCHECK_CSV_CHANGED = "Output CSV file changed one or more values."
DFCHECK_CSV_COLUMNS = "Output CSV file changed number of columns."
DFCHECK_DIFFERENT_BITS = "Dataset has different BIDS bits w.r.t. reference."
DFCHECK_DIFFERENT_LENGTH = (
    "Input datases have different lengths (input={len_input}, reference={len_reference})."
)
DFCHECK_IQMS_CORRELATED = "All IQMs show a Pearson correlation >= 0.95."
DFCHECK_IQMS_UNDER_095 = "IQMs with Pearson correlation < 0.95:\n{iqms}"
SUBJECT_WRANGLER_DESCRIPTION = """\
BIDS-Apps participants wrangler tool
------------------------------------

This command arranges the participant labels in groups for computation, and checks that the \
requested participants have the corresponding folder in the bids_dir.\
"""
