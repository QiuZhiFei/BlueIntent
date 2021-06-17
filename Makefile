.PHONY: help

run:
	cd Example && pod install --no-repo-update --verbose
	open Example/BlueIntent.xcworkspace/

lint:
	pod lib lint --allow-warnings --verbose

deploy:
	pod trunk push BlueIntent.podspec --allow-warnings --verbose

help: 
	@echo targes:  run, lint, deploy
