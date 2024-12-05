# repo-opener

This script opens the website of the repo you are currently in if it can find details in the following places:

- composer.json
- .git/config 

If it can get a 'name' from compsoer.json it assumes the url is at https://github.com/{name} . 

It works on linux

## Installation 

`install.sh` just puts a symlink in your ~/bin/ dir (creating one if required). You should ensure that ~/bin/ is 
in your `$PATH`. 

## Usage 

cd into a director, then run `repo-opener`

