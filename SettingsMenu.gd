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
