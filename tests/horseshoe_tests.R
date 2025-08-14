
# horseshoe_tests.R
library(shhR)

samples <- 5000
modulus_val <- 2^16

test_horseshoe_quality <- function(num_samples=samples, mod=modulus_val) {
  #inputs <- paste0(paste0("INPUT", "_"), seq_len(num_samples))
  inputs <- paste0("INPUT_", seq_len(num_samples))
  hashes <- sapply(inputs, horseshoe_hash, mod=mod)

  # print out a few here
  cat("Inputs ::")
  cat(head(inputs), "\n")
  
  cat("Hashes :: ")
  cat(head(hashes), "\n")
  
  # Collision rate
  unique_hashes <- length(unique(hashes))
  collision_rate <- 1 - (unique_hashes / num_samples)

  # Uniformity test: chi-squared
  counts <- table(hashes)
  expected <- num_samples / length(counts)
  chi_sq <- sum((counts - expected)^2 / expected)

  list(
    num_samples=num_samples,
    unique_hashes=unique_hashes,
    collision_rate=collision_rate,
    chi_sq=chi_sq,
    p_value=pchisq(chi_sq, df=length(counts)-1, lower.tail=FALSE)
  )
}

# Example run
print(test_horseshoe_quality())
