Welcome to the Dogsbody Workstation tools repo
==============================================
This is a collection of tools and scripts we use on our personal workstations.
We mainly use Ubuntu so you can expect the tools to have been tested there.
They will be written in the best tool for the job (BASH or Python 3 :P )


Getting started
---------------
An aim for this repository is to be as modular as possible 

```shell
cd /path/to/this/repo

# If you want to install all packages
make all

# If you only want the patch-on-startup tool set up
make patch-on-startup
```


Development notes
-----------------
If you are developing any tools for this repo please follow these points:
* New directory for each tool
* Include a setup script in your directory 
  * Update the main Makefile to tie into that script
* If your script is at all complex create its own README file/documentation in its directory
* If there are any variables that need setting for your script to work they should be prompted by the make file
  * And then stored in a file called "settings.local" in the script directory. 
  * This file is automatically git ignored. 
* Any shared settings/resources/librarys should go in the "shared" directory. 
  * Further shared item segregation is detailed in the "shared" README file. 
  