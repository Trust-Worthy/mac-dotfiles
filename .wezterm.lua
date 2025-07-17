return {
        initial_cols = 120,  -- Optional: Set initial width
        initial_rows = 40,   -- Optional: Set initial height
        -- window_decorations = "NONE",  -- Removes window borders for a true fullscreen effect
        native_macos_fullscreen_mode = true,

        -- Opacity settings
        window_background_opacity = 0.6,  -- Adjust transparency (0.0 = fully transparent, 1.0 = fully opaque)
        -- macos_window_background_blur = 0, -- Only on macOS

        colors = {
    foreground = "#66d9ef",  -- Teal text color
    background = "#1b1f23",  -- Dark background (complementary to teal)
    cursor_bg = "#f39c12",   -- Bright orange cursor (complementary color)
    ansi = {
      "#1b1f23", -- Black (Background color)
      "#f39c12", -- Red (Complementary to teal)
      "#5af78e", -- Green
      "#f3f99d", -- Yellow
      "#57c7ff", -- Blue
      "#ff6ac1", -- Magenta
      "#00bfae", -- Cyan
      "#d7d7d7", -- White
    },
    brights = {
      "#2c3138", -- Bright Black
      "#f39c12", -- Bright Red
      "#5af78e", -- Bright Green
      "#f3f99d", -- Bright Yellow
      "#57c7ff", -- Bright Blue
      "#ff6ac1", -- Bright Magenta
      "#00e0c6", -- Bright Cyan
      "#ffffff", -- Bright White
    },
  }
}
