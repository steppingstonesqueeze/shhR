
# horseshoe_viz.R
library(shhR)
library(ggplot2)

visualize_horseshoe <- function(mod=50, rounds=3, stretch=3, compress=2) {
  grid <- expand.grid(x=0:(mod-1), y=0:(mod-1))
  coords <- as.matrix(grid)

  all_points <- data.frame()

  for (r in 0:rounds) {
    df <- data.frame(x=coords[,1], y=coords[,2], round=r)
    all_points <- rbind(all_points, df)
    if (r < rounds) {
      next_coords <- horseshoe_round(coords[,1], coords[,2], mod, stretch, compress)
      coords <- next_coords
    }
  }

  ggplot(all_points, aes(x, y)) +
    geom_point(size=0.4) +
    facet_wrap(~round) +
    coord_fixed() +
    theme_minimal() +
    ggtitle("Discrete Smale's Horseshoe Rounds")
}

# run it
visualize_horseshoe(mod=50, rounds=4, stretch=3, compress=2)

# visualise how neighbourhood points move to see the effects of sensitivity to initial conditions
# Chaos, here we come

visualize_neighborhood_scattering <- function(
    mod = 50, rounds = 4, stretch = 3, compress = 2,
    center = c(25, 25), radius = 2) {
  
  # Generate neighborhood points
  x_vals <- (center[1] - radius):(center[1] + radius)
  y_vals <- (center[2] - radius):(center[2] + radius)
  x_vals <- x_vals[x_vals >= 0 & x_vals < mod]
  y_vals <- y_vals[y_vals >= 0 & y_vals < mod]
  
  grid <- expand.grid(x = x_vals, y = y_vals)
  coords <- as.matrix(grid)
  
  # Assign a unique color ID
  grid$id <- seq_len(nrow(grid))
  
  all_points <- data.frame()
  
  for (r in 0:rounds) {
    df <- data.frame(x = coords[, 1], y = coords[, 2],
                     round = r, id = grid$id)
    all_points <- rbind(all_points, df)
    
    if (r < rounds) {
      next_coords <- horseshoe_round(coords[, 1], coords[, 2],
                                     mod, stretch, compress)
      coords <- next_coords
    }
  }
  
  ggplot(all_points, aes(x, y, color = factor(id))) +
    geom_point(size = 2) +
    facet_wrap(~round) +
    coord_fixed() +
    theme_minimal() +
    scale_color_viridis_d(option = "plasma") +
    labs(title = "Neighborhood Scattering in Discrete Smale's Horseshoe",
         color = "Point ID")
}

# Example run
visualize_neighborhood_scattering(mod = 50, rounds = 4, stretch = 3, compress = 2, radius = 1)

# track distance between neighbouring points across rounds - visualise the divergences

track_point_distance <- function(p1, p2, mod = 50, rounds = 10,
                                 stretch = 3, compress = 2) {
  # Store distances
  distances <- numeric(rounds + 1)
  
  # Initial distance
  dist_fun <- function(a, b) sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2)
  distances[1] <- dist_fun(p1, p2)
  
  # Current coords
  c1 <- p1
  c2 <- p2
  
  # Iterate rounds
  for (r in 1:rounds) {
    c1 <- horseshoe_round(c1[1], c1[2], mod, stretch, compress)
    c2 <- horseshoe_round(c2[1], c2[2], mod, stretch, compress)
    distances[r + 1] <- dist_fun(c1, c2)
  }
  
  # Data frame for plotting
  df <- data.frame(round = 0:rounds, distance = distances)
  
  # Plot
  ggplot(df, aes(x = round, y = distance)) +
    geom_line(color = "blue") +
    geom_point(color = "red", size = 2) +
    theme_minimal() +
    labs(title = sprintf("Distance growth: (%.3f,%.3f) vs (%.3f,%.3f)",
                         p1[1], p1[2], p2[1], p2[2]),
         x = "Round", y = "Euclidean distance")
}

# Example usage
track_point_distance(c(1, 1), c(2, 1), mod = 50, rounds = 20, stretch = 3, compress = 2)