extends Node

# ============================================================
# UITheme.gd — Shared Teal/Blue Theme System
# ============================================================
# Autoload providing consistent UI styling across all screens.
# Usage: UITheme.style_button(button) in any scene's _ready()
# ============================================================

# === COLOR PALETTE ===
var COLOR_TEAL = Color(0.10, 0.54, 0.62, 1.0)
var COLOR_TEAL_LIGHT = Color(0.15, 0.63, 0.72, 1.0)
var COLOR_TEAL_DARK = Color(0.08, 0.41, 0.47, 1.0)
var COLOR_BLUE_ACCENT = Color(0.12, 0.53, 0.90, 1.0)
var COLOR_PANEL_BG = Color(0.93, 0.95, 0.98, 0.95)
var COLOR_PANEL_BORDER = Color(0.60, 0.72, 0.85, 0.85)
var COLOR_TEXT_WHITE = Color(1.0, 1.0, 1.0, 1.0)
var COLOR_TEXT_LIGHT = Color(0.80, 0.88, 0.95, 1.0)
var COLOR_TEXT_DARK = Color(0.08, 0.15, 0.25, 1.0)
var COLOR_TEXT_MUTED = Color(0.30, 0.40, 0.50, 1.0)
var COLOR_TITLE_PILL = Color(0.10, 0.45, 0.58, 0.9)
var COLOR_BODY_PILL = Color(0.12, 0.48, 0.52, 0.75)

# === SIZING ===
var BUTTON_RADIUS = 22
var PANEL_RADIUS = 14
var PILL_RADIUS = 25
var PANEL_BORDER = 3

# === FONT CACHE ===
var _font_cache = {}

func get_font(size: int) -> DynamicFont:
	if size in _font_cache:
		return _font_cache[size]
	var fd = DynamicFontData.new()
	fd.font_path = "res://BebasNeue-Regular.ttf"
	var f = DynamicFont.new()
	f.font_data = fd
	f.size = size
	_font_cache[size] = f
	return f

# === STYLEBOX FACTORY ===

func _make_box(bg: Color, radius: int = BUTTON_RADIUS,
               border_col: Color = Color.transparent, border_w: int = 0,
               margin_h: int = 16, margin_v: int = 8) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	if border_w > 0:
		s.border_width_top = border_w
		s.border_width_bottom = border_w
		s.border_width_left = border_w
		s.border_width_right = border_w
		s.border_color = border_col
	s.content_margin_left = margin_h
	s.content_margin_right = margin_h
	s.content_margin_top = margin_v
	s.content_margin_bottom = margin_v
	s.anti_aliasing = true
	return s

# === BUTTON STYLING ===

func style_button(btn: Button, font_size: int = 22):
	btn.add_stylebox_override("normal", _make_box(COLOR_TEAL))
	btn.add_stylebox_override("hover", _make_box(COLOR_TEAL_LIGHT))
	btn.add_stylebox_override("pressed", _make_box(COLOR_TEAL_DARK))
	btn.add_stylebox_override("focus", _make_box(COLOR_TEAL, BUTTON_RADIUS, COLOR_BLUE_ACCENT, 2))
	btn.add_stylebox_override("disabled", _make_box(Color(0.25, 0.25, 0.30, 0.6)))
	btn.add_font_override("font", get_font(font_size))
	btn.add_color_override("font_color", COLOR_TEXT_WHITE)
	btn.add_color_override("font_color_hover", COLOR_TEXT_WHITE)
	btn.add_color_override("font_color_pressed", Color(0.75, 0.88, 1.0, 1.0))
	btn.add_color_override("font_color_disabled", Color(0.5, 0.5, 0.5, 1.0))

# === PANEL STYLING ===

func style_panel_dark(panel):
	var s = _make_box(COLOR_PANEL_BG, PANEL_RADIUS, COLOR_PANEL_BORDER, PANEL_BORDER, 20, 20)
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 10
	panel.add_stylebox_override("panel", s)

# === LABEL STYLING ===

func style_label(label: Label, size: int = 18, color: Color = COLOR_TEXT_WHITE):
	label.add_font_override("font", get_font(size))
	label.add_color_override("font_color", color)

func style_label_with_pill(label: Label, pill_color: Color, font_size: int = 22):
	var pill = _make_box(pill_color, PILL_RADIUS, Color.transparent, 0, 20, 10)
	label.add_stylebox_override("normal", pill)
	label.add_font_override("font", get_font(font_size))
	label.add_color_override("font_color", COLOR_TEXT_WHITE)
