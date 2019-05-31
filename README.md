# Slack status updater

A simple shell script to update your status in Slack from the command line,
based on presets you provide in a configuration file.

## Installation

Copy `slack_status.sh` to somewhere in your path.

## Setup

First, you need to get an API token. Go to
<https://api.Slack.com/custom-integrations/legacy-tokens> and grab the token
for your workspace. If you don't already have a token for your workspace, click the
'Request token' button next to the workspace to get a token.

Once you have the token, run `slack_status.sh setup` and follow the prompts.
This will create a configuration file for you.

If you wish, edit the configuration file to add additional presets.

## Usage

* `slack_status.sh PRESET` - updates your Slack status to the preset
* `slack_status.sh none` - resets your Slack status to be blank
* `slack_status.sh PRESET ADDITIONAL TEXT` - any additional text you type will
  be added to the end of your Slack status.

Example:

```
$ slack_status.sh test
Updating status to: :check: Testing status updater
$ slack_status.sh none
Updating status to:
$ slack_status.sh vacation
Updating status to: :hotel: On vacation
$ slack_status.sh vacation until June 15
Updating status to: :hotel: On vacation until June 15
```

## Plugins

### Video conference plugin

Included is a plugin for Hammerspoon that will automatically set your
status appropriately when you are in a [Zoom](https://zoom.us) or
[BlueJeans](https://bluejeans.com) meeting.

To install it:

* Install and set up the `slack_status.sh` script (make sure it's in your path)
* Ensure there is a `videoconference` preset (one is created by default during setup)
* Install Hammerspoon (`brew cask install hammerspoon`) if you don't have it already.
* Symlink the `videoconference_detect.lua`, `bluejeans.lua`, and `zoom.lua` files to
`~/.hammerspoon/`
* Add the following lines to `~/.hammerspoon/init.lua`:

```
local videoconference_detect = require("videoconference_detect")
local bluejeans = require("bluejeans")
local zoom = require("zoom")
```
