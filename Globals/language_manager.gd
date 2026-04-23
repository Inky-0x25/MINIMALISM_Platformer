extends Node

var supported_languages = ["en", "it", "zh", "ja"]

func set_language(locale: String):
	if locale in supported_languages:
		GlobalVar.current_language = locale
		TranslationServer.set_locale(locale)

func get_language() -> String:
	return GlobalVar.current_language
