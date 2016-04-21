# This function will merge a list of hashes, ignoring key => value pairs in the
# the latter which have a value of `undef`
#
# @param original [Hash] The base hash. All key values from this will be included.
#
# @param *to_merge [Hash] A variable number of hashes to merge in. Each of these
#   will have its key => value pairs added to the original hash, except where
#   the value is `undef`. Later values will override earlier values.
#
function jmxtrans::merge_notundef(Hash $original, Hash *$to_merge) {
  $to_merge.reduce($original) |$memo1, $new_hash| {
    $new_hash.reduce($original) |$memo, $data| {
      $key = $data[0]
      $value = $data[1]
      if $value {
        $memo + { $key => $value }
      } else {
        $memo
      }
    }
  }
}
