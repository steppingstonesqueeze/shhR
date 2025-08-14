
# horseshoe_hash.R
# Discrete Smale's Horseshoe-style non-crypto hash

# Convert string to integer seeds
string_to_xy <- function(s, mod) {
  raw_vals <- utf8ToInt(s)
  x <- sum(as.integer(raw_vals) * 31^(seq_along(raw_vals)-1)) %% mod
  y <- sum(as.integer(rev(raw_vals)) * 17^(seq_along(raw_vals)-1)) %% mod
  return(c(x, y))
}

# One round of discrete horseshoe
horseshoe_round <- function(x, y, mod, stretch=3, compress=2) {
  # Stretch x, compress y
  x <- (x * stretch) %% mod
  y <- (y %/% compress) %% mod

  # Fold: flip half the strip in x
  half <- mod %/% 2
  mask <- x >= half
  x[mask] <- mod - x[mask] - 1

  return(cbind(x, y))
}

# Main hash function
horseshoe_hash <- function(s, rounds=4, mod=2^16, stretch=3, compress=2) {
  coords <- string_to_xy(s, mod)
  x <- coords[1]; y <- coords[2]
  for (r in 1:rounds) {
    coords <- horseshoe_round(x, y, mod, stretch, compress)
    x <- coords[,1]; y <- coords[,2]
  }
  # Combine x and y into single integer hash
  return( bitwXor(x, bitwShiftL(y, 8)) %% mod )
}
