/**
 * CSS overrides — small user-authored `.css` files in
 * `~/.config/zennotes/overrides/` that the user toggles on/off and that layer on
 * top of *whichever* theme is active (built-in or custom). The enabled set is
 * persisted as a portable config map (`[overrides]` in config.toml).
 *
 * To override a theme token from a override, target `:root[data-theme] { … }` —
 * overrides are injected last, so that selector wins over both a built-in's
 * `:root[data-theme="…"]` block and a custom theme's `:root {}`.
 */

export interface Override {
  /** Filename including `.css`, e.g. `punchy-accent.css`. Stable id. */
  name: string
  /** Raw CSS text, injected verbatim when enabled. */
  css: string
  /** Set when the file couldn't be read; surfaced in the UI. */
  error?: string
}

/**
 * Whether a override is enabled, per the persisted `[overrides]` map. Only enabled
 * overrides are stored (`"name.css" = "on"`); a missing key means off. Tolerant
 * of a hand-edited config that wrote an explicit off-ish value.
 */
export function isOverrideEnabled(
  enabled: Record<string, string> | undefined,
  name: string
): boolean {
  const v = enabled?.[name]
  return v !== undefined && v !== 'off' && v !== 'false' && v !== '0' && v !== ''
}
