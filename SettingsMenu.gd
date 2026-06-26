extends Control

signal closed

onready var music_slider = $Panel/MusicVolume/MusicSlider
onready var music_val_label = $Panel/MusicVolume/MusicValueLabel
onready var sfx_slider = $Panel/SFXVolume/SFXSlider
onready var sfx_val_label = $Panel/SFXVolume/SFXValueLabel
onready var back_button = $Panel/BackButton

func _ready():
	# Retrieve initial volume values from AudioManager
	music_slider.value = AudioManager.volume_music
	sfx_slider.value = AudioManager.volume_sfx
	
	_update_music_label(AudioManager.volume_music)
	_update_sfx_label(AudioManager.volume_sfx)
	
	# Connect signals
	music_slider.connect("value_changed", self, "_on_MusicSlider_value_changed")
	sfx_slider.connect("value_changed", self, "_on_SFXSlider_value_changed")
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	
	# Connect button hover signals to play click sound if needed
	back_button.connect("mouse_entered", self, "_on_button_hover")
	
	# Apply teal/blue theme
	UITheme.style_panel_dark($Panel)
	UITheme.style_label($Panel/TitleLabel, 26)
	UITheme.style_label($Panel/ControlsLabel, 22)
	UITheme.style_button(back_button)
	
	# Style volume labels
	UITheme.style_label($Panel/MusicVolume/Label, 18, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_label($Panel/SFXVolume/Label, 18, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_label($Panel/MusicVolume/MusicValueLabel, 16, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_label($Panel/SFXVolume/SFXValueLabel, 16, UITheme.COLOR_TEXT_LIGHT)
	
	# Style separator
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = UITheme.COLOR_BLUE_ACCENT
	sep_style.content_margin_top = 1
	sep_style.content_margin_bottom = 1
	$Panel/Separator.add_stylebox_override("separator", sep_style)
	
	# Style controls grid labels
	for child in $Panel/GridContainer.get_children():
		if child is Label:
			UITheme.style_label(child, 16, UITheme.COLOR_TEXT_LIGHT)

func _on_MusicSlider_value_changed(value):
	AudioManager.set_music_volume(value)
	_update_music_label(value)

func _on_SFXSlider_value_changed(value):
	AudioManager.set_sfx_volume(value)
	_update_sfx_label(value)

func _update_music_label(value):
	music_val_label.text = str(int(value)) + "%"

func _update_sfx_label(value):
	sfx_val_label.text = str(int(value)) + "%"

func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	emit_signal("closed")

func _on_button_hover():
	# Standard hover effect feedback could go here if desired
	pass
