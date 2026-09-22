#!/usr/bin/env bash
#
# cleanup_originals.sh — remove the intermediate results, figures and raw dataset
# files that were deliberately left out of the consolidated IID project.
#
# Everything this script deletes is either:
#   (A) regenerable by re-running the pipeline  (.mat/.fig/.tif/.png/.asv/...), or
#   (B) a raw dataset file re-obtainable from the original public source
#       (HDM05, Berkeley MHAD, Auslan/UCI KDD, MSRC-12).
#
# ALL CODE IS LEFT IN PLACE.  Only the extensions listed below are touched.
#
# NOTE: these paths are on an SMB share — deletions there do NOT go to the Trash
#       and cannot be undone.
#
# Usage:
#   ./cleanup_originals.sh            # dry run: prints what WOULD be deleted
#   ./cleanup_originals.sh --apply    # actually delete
#
set -uo pipefail

WORK="/Volumes/OneTouch/MatlabProjects/work"

# LOCAL is where the *cleanup targets* live.  It stays pointed at the old MATLAB
# workspace even though IID itself now lives one level up, in Projects/.
LOCAL="/Users/perryshao/Documents/Projects/Work"

# IID is resolved from this script's own location (tools/ sits one level below the
# project root), so the project can be relocated without editing this file.
IID="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

if [ ! -d "$WORK" ]; then
    echo "ERROR: $WORK not found." >&2
    echo "The OneTouch SMB share is not mounted (or the mount went stale)." >&2
    echo "Reconnect it in Finder — Go > Connect to Server:" >&2
    echo "    smb://perry-System-Product-Name._smb._tcp.local/OneTouch" >&2
    echo "then re-run this script.  Nothing was touched." >&2
    exit 1
fi
if [ ! -d "$IID/core" ]; then
    echo "ERROR: $IID looks incomplete — refusing to delete anything." >&2
    exit 1
fi

EXPDIRS=(HDM05EvaluatingCode MHADEvaluatingCode ASLEvaluatingCode MicrosoftGestureEvaluatingCode)

# (A) intermediate results and figures
EXT_A=(-name '*.mat' -o -name '*.fig' -o -name '*.tif' -o -name '*.png'
       -o -name '*.asv' -o -name '*.eps' -o -name '*.log' -o -name '*.mp4'
       -o -name '*.avi' -o -name '*.jpg')

# (B) raw dataset files
EXT_B=(-iname '*.c3d' -o -name '*.sign' -o -name '*.tsd' -o -name '*.txt'
       -o -name '*.tagstream' -o -name '*.csv' -o -name '*.bvh' -o -name '*.amc')

total=0

sweep () {          # $1 = directory, $2 = label, shift 2 = find expression
    local dir="$1" label="$2"; shift 2
    [ -d "$dir" ] || { echo "  skip (missing): $dir"; return; }
    local n bytes
    n=$(find "$dir" -type f \( "$@" \) 2>/dev/null | wc -l | tr -d ' ')
    bytes=$(find "$dir" -type f \( "$@" \) -exec stat -f%z {} + 2>/dev/null \
            | awk '{s+=$1} END {printf "%.0f", s}')
    bytes=${bytes:-0}
    total=$((total + bytes))
    printf "  %-34s %6s files  %8.1f MB  [%s]\n" \
           "$(basename "$dir")" "$n" "$(echo "$bytes/1048576" | bc -l)" "$label"
    if [ "$APPLY" = "1" ] && [ "$n" -gt 0 ]; then
        find "$dir" -type f \( "$@" \) -delete 2>/dev/null
    fi
}

echo "=== (A) intermediate results and figures ==="
for d in "${EXPDIRS[@]}"; do sweep "$WORK/$d" A "${EXT_A[@]}"; done
sweep "$WORK/analysis data" A "${EXT_A[@]}"

echo
echo "=== (B) raw dataset files ==="
for d in "${EXPDIRS[@]}"; do sweep "$WORK/$d" B "${EXT_B[@]}"; done

echo
echo "=== (D) top-level paper figures and MATLAB autosaves ==="
TOPLEVEL=("maximal segment.fig" "occluded_trajectory.fig" "path.fig" "path.tif"
          "cartwheel.fig" "cartwheel.tif" "figure_body.fig" "figure_body.tif"
          "feature_dist_orien_integral_matrix.asv"
          "recognition_dtw_hdm_compact_bat.asv")
for f in "${TOPLEVEL[@]}"; do
    if [ -f "$WORK/$f" ]; then
        sz=$(stat -f%z "$WORK/$f" 2>/dev/null || echo 0)
        total=$((total + sz))
        printf "  %-46s %8s\n" "$f" "$(du -h "$WORK/$f" | cut -f1)"
        [ "$APPLY" = "1" ] && rm -f "$WORK/$f"
    fi
done

# The SMB share has dropped mid-session before.  Confirm it is still there before
# we trust anything reported above: find's errors are sent to /dev/null, so a share
# that vanished mid-sweep would otherwise look like a clean run.
SHARE_LOST=0
if [ ! -d "$WORK" ] || [ ! -d "$WORK/${EXPDIRS[0]}" ]; then
    SHARE_LOST=1
    echo >&2
    echo "!! WARNING: the OneTouch share is no longer reachable." >&2
    echo "!! The figures above for (A), (B) and (D) are NOT reliable and the sweep" >&2
    echo "!! may have stopped part-way.  Reconnect the share and re-run:" >&2
    echo "!!   - a dry run will show what is genuinely left" >&2
    echo "!!   - re-running with --apply is safe, it simply resumes" >&2
    echo >&2
fi

if [ "$APPLY" = "1" ] && [ "$SHARE_LOST" = "0" ]; then
    echo
    echo "=== pruning directories left empty ==="
    for d in "${EXPDIRS[@]}"; do
        find "$WORK/$d" -type d -empty -delete 2>/dev/null
    done
    find "$WORK/analysis data" -type d -empty -delete 2>/dev/null
fi

# ---------------------------------------------------------------------------
# (E) local source folders, now fully superseded by IID
#
# Each was verified byte-for-byte against IID before this script was written:
#   Determine_segment_Linux/  9/9 files identical to IID/mbs/{src,bin}
#   Determine_segment_Mac/    9/9 files identical to IID/mbs/{src,bin}
#   Validation 3 Clean/       every .m/.cpp/.h/.mex/.txt preserved in IID
#                             (remainder is 186 MB of .mat/.fig/.csv/.xlsx/.png)
#
# The guard below re-verifies that every code file still has a content match
# inside IID and REFUSES to delete a folder if anything is unaccounted for.
# ---------------------------------------------------------------------------
echo
echo "=== (E) local folders superseded by IID ==="

find "$IID" -type f -exec md5 -q {} \; 2>/dev/null | sort -u > /tmp/iid_hashes.$$

check_and_drop () {
    local dir="$1"
    [ -d "$dir" ] || { echo "  skip (missing): $(basename "$dir")"; return; }
    local uncovered=0
    while IFS= read -r f; do
        grep -qx "$(md5 -q "$f")" /tmp/iid_hashes.$$ || {
            echo "    !! not in IID: ${f#$dir/}"; uncovered=$((uncovered+1)); }
    done < <(find "$dir" -type f \
                ! -name '*.mat' ! -name '*.fig' ! -name '*.png' ! -name '*.csv' \
                ! -name '*.xlsx' ! -name '.DS_Store' ! -name '._*' 2>/dev/null)

    local sz; sz=$(du -sh "$dir" 2>/dev/null | cut -f1)
    if [ "$uncovered" -gt 0 ]; then
        printf "  %-28s %8s  REFUSED — %d file(s) exist only here\n" \
               "$(basename "$dir")" "$sz" "$uncovered"
        return
    fi
    printf "  %-28s %8s  fully superseded\n" "$(basename "$dir")" "$sz"
    local bytes; bytes=$(find "$dir" -type f -exec stat -f%z {} + 2>/dev/null \
                         | awk '{s+=$1} END {printf "%.0f", s}')
    total=$((total + ${bytes:-0}))
    [ "$APPLY" = "1" ] && rm -rf "$dir"
}

check_and_drop "$LOCAL/Determine_segment_Linux"
check_and_drop "$LOCAL/Determine_segment_Mac"

rm -f /tmp/iid_hashes.$$

# 'Validation 3 Clean' is NOT removed wholesale — it still holds the original
# ToZP/ RRV descriptor, which is to be kept in place.  Only its recorded data
# and figures are swept; every .m / .cpp / .h / .mex file stays, ToZP included.
# (Code-wise this folder is fully duplicated in IID/validation/ already.)
echo
echo "=== (F) 'Validation 3 Clean' — data and figures only, ToZP/ preserved ==="
EXT_VAL=(-name '*.mat' -o -name '*.fig' -o -name '*.png'
         -o -name '*.csv' -o -name '*.xlsx' -o -name '.DS_Store')
sweep "$LOCAL/Validation 3 Clean" F "${EXT_VAL[@]}"
if [ -d "$LOCAL/Validation 3 Clean/ToZP" ]; then
    echo "  kept: ToZP/ ($(find "$LOCAL/Validation 3 Clean/ToZP" -type f | wc -l | tr -d ' ') files)"
else
    echo "  WARNING: ToZP/ not found where expected" >&2
fi

echo
if [ "$SHARE_LOST" = "1" ]; then
    printf "TOTAL (UNRELIABLE — share dropped mid-run): %.2f GB\n" \
           "$(echo "$total/1073741824" | bc -l)"
    echo "Reconnect the OneTouch share and re-run before trusting this number." >&2
    exit 3
fi
printf "TOTAL: %.2f GB across %s\n" "$(echo "$total/1073741824" | bc -l)" \
       "$( [ "$APPLY" = "1" ] && echo 'DELETED' || echo 'would be deleted (dry run)')"
if [ "$APPLY" != "1" ]; then
    echo
    echo "This was a DRY RUN. Re-run with --apply to actually delete."
fi
