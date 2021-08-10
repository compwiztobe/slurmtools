# move to this directory
cd "$(dirname "$0")"

# for all checkpoint dirs
for d in checkpoints/*/; do
  # for every numbered checkpoint
  for c in $(find $d -type f -iregex '^.*[0-9]+\.pt$'); do
    # is it the same as the best checkpoint?
    cmp -s "$c" "${d}checkpoint_best.pt" &&
      # if so, say so (and also check if it's same as last)
      (echo -ne "$c is best"; cmp -s "$c" "${d}checkpoint_last.pt" && echo " and last" || echo) ||
      # if not, check if it's the same as the last, and if not delete it (neither best nor last)
      (cmp -s "$c" "${d}checkpoint_last.pt" && echo "$c is last" || rm "$c");
  done;
done
