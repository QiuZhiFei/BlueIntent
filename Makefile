.PHONY: help

lint:
	pod lib lint --allow-warnings --verbose

deploy:
	pod trunk push BlueIntent.podspec --allow-warnings --verbose

help: 
	@echo targes:  lint, deploy
