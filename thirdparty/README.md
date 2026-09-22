# Third-party code

These toolboxes are **not** covered by this project's GPL-3.0 licence. Each remains
under its own authors' copyright and terms. They are bundled only because the pipeline calls
into them directly and they are small; each was reduced to code only, with bundled
datasets, docs and VCS metadata stripped.

| Toolbox | Needed by | Licence |
|---|---|---|
| `C3D`, `c3d_matlab` | `load_c3d*.m` — reading HDM05 / MHAD mocap | no licence file found |
| `HDM05-Parser` | `load_bvh_bat.m` | no licence file; © Neil D. Lawrence (2005, 2008) in source headers |
| `mocap-bvh-toolbox` | `bvhReadFile` / `skel2xyz`, used by `HDM05-Parser` | no licence file; © Neil D. Lawrence (2005, 2006) in source headers |
| `PG_Curve-master` | `draw_cm`, `compute_precision_recall` — confusion matrices and PR curves in all four `trajectory_matching.m` | no licence file found |
| `SpectralClustering` | `Spec_Clustering`, `RankOneDecom_Feaures` — every `recognition_dtw_*` script | no licence file found |
| `edit_distances` | `matching/ned_distance.m` | `license.txt` (BSD) |

> ⚠️ Five of these six shipped without a licence file, so their redistribution terms
> are unclear. They are included here for convenience; if that is a problem for your
> use, delete `thirdparty/` and obtain each from its original source — nothing else in
> the project needs changing except adding them to the MATLAB path.

## Removed toolboxes

Six toolboxes that the original workspace carried were **not** kept, because nothing on
the papers' critical path uses them. All three papers classify with **1-NN over the DTW
inter-descriptor distance**; SVM, HMM, bag-of-visual-words and sparse coding were
explored but never used for a published result, and every one of their entry points
(`mhmm_classifier`, `gene_codebook`, `gene_codebook_ScSPM`, `trainHMM`, `train_libsvm`,
`construct_hmmdata`) is called by nothing in this project.

Dropping them removed 2050 files and 11 MB — and with `bnt`, a GPL dependency whose
copyleft would otherwise have constrained this project's own licence.

| Removed | Was needed by | Get it from |
|---|---|---|
| `libsvm-3.17` | `utils/train_libsvm.m`, `experiments/ASL/recognition_dtw_tsd_bat.m` | <https://www.csie.ntu.edu.tw/~cjlin/libsvm/> |
| `bnt` (GPL) + `HMMall` | `experiments/ASL/mhmm_classifier.m`, `mhmm_classifier_cluster.m`; `experiments/MSRC12/mhmm_classifier.m`, `trainHMM.m` | <https://github.com/bayesnet/bnt> |
| `computeBoV` | `experiments/{ASL,MSRC12}/gene_codebook.m`, `gene_codebook_pyramid.m` | author's original distribution |
| `ScSPM`, `fast_sc` | `experiments/{ASL,MSRC12}/gene_codebook_ScSPM.m` | <https://github.com/jianchao-li/ScSPM> (Jianchao Yang) |

Those twelve scripts are kept — they are the author's own exploratory work — but they
**cannot run** until the corresponding toolbox is installed and added to the path.
Nothing else in the project calls them, so the published pipeline is unaffected.
