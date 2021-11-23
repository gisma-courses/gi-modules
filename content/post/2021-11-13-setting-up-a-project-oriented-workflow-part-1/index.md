---
title: Setting up a project-oriented workflow - Part 1
author: Chris Reudenbach
date: '2021-11-13'
slug: []
categories:
  - Prerequisites
tags:
  - Setup
description: 'We value freedom of choice as an important good but giving our long-term experience freedom of choice comes to an end when we talk about the mandatory working environment for this course.'

---

To set up a working or project environment, (normally) the first steps are defining different folder paths and loading the necessary R packages as well as additional functions.


If you also need to access additional software, like GIS, the appropriate binaries and software environments must be linked, too. Factoring in the major operating systems and the potentially multiple versions of software installed on a single system results in almost unlimited combinations of set ups.

## Flexible but reproducible setup

We value freedom of choice as an important good. But given our long-term experience as instructors of similar courses, there is **no freedom of choice** when it comes to the mandatory working environment for this course. The reason for this is simple: Assignments and chunks of code written on person A's laptop should run on person B's computer without requiring any changes. The greater the number of systems that should be able to run the code, the nastier this potential situation can become. So, let's save everyone's time and focus on the things that are really important. Once the course is finished, feel free to use any working environment structure you like.

## R project frameworks
Setting up a working or project environment requires us to define different folder paths and load necessary R packages and additional functions. If, in addition, external APIs (application programming interface) are to be integrated stably and without great effort, the associated paths and environment variables must also be defined correctly. 

There are several R packages, such as e.g. [tinyProject](https://github.com/FrancoisGuillem/tinyProject){:target="_blank"},  [workflowR](https://jdblischak.github.io/workflowr/){:target="_blank"} or [usethis](https://usethis.r-lib.org/){:target="_blank"}, that provide a wide range of functions for such issues. For this introduction to a structured organization of R-based development projects, we suggest a slimmed down version. 

## Introduction of the `envimaR` helper package 
It would be convenient if the *mandantory* folders were created and initialized automatically. For the needs of this course, we have written a small project management package called `envimaR` that takes care of these tasks. It is located on `github` and can be installed as follows.

```r
devtools::install_github("envima/envimaR")
```

Essentially, a project may be split at least in three categories of tasks:

- data 
- scripts
- documentation

The basis of the aforementioned categories is an adequate storage structure on a suitable permanent storage medium (hard disk, USB stick, cloud, etc.). We suggest a meaningful hierarchical directory structure. 

## Coping with different absolute paths across different computers
The biggest problem when it comes to cross-computer project path environments is not the project environment itself, i.e. the subfolders of your project *relative* to your project folder but the *absolute* path to your project folder. Imagine you agreed on a project folder called mpg-envinsys-plygrnd. On the laptop of person A, the absolute path to the root folder might be `C:\Users\UserA\University\mpg-courses\gi` while on the external hard disk of person B it might be `X:\university_courses\mpg-courses\gi`. If you want to read from your data subfolder you have to change the absolute directory path depending on which computer the script is running. Not good.

One solution to this problem is to agree on a common structure *relative* to your individual R home directory using symbolic links (Linux flavor systems) or junctions (Windows flavor systems).
{: .notice--success}

Example: Create a top-level folder name which hosts all of your student projects. For example, this folder is called `edu`. Within `edu`, the project folder of this course is called `course-name-provided-by-the-instructor`. Create the folder `edu` anywhere you want, e.g. at `D:\stuff\important\edu`. Then create a so called symbolic link to this folder within your R home directory i.e. the directory where the R function `path.expand("~")` points to.

To create this link on Windows flavor systems, start a command prompt window (e.g. press [Windows], type "CMD", press [Return]) and change the directory of the command prompt window to your R home directory which is by default `C:\Users\your-user-name\Documents`. Then use the `mklink \J` command to create the symbolic link. In summary and given the paths above:

```yaml
cd C:\Users\your-user-name\Documents
mklink /J edu D:\stuff\important\edu
```

On Linux flavor systems, the R home directory is your home directory by default, i.e. `/home/your-user-name/`. If you create your edu folder on `/media/memory/interesting/edu`, the symbolic link can be created using your bash environment:

```yaml
cd /home/<your-user-name>/
ln -s /media/memory/interesting/edu edu
```
Now one can access the `edu` folder on both the Windows and the Linux example via the home directory, i.e. `~/edu/`. All problems solved.


While this will work on all of your private computers, it will **not** work on the ones in the University's computer lab. To handle that as smooth as possible, you can use the functionality of the `envimaR` package which allows to set defaults for all computers but one special type which is handled differently. 
{: .notice--info}

## Basic workflow of the setup procedure

There are two aspects we would draw your attention to:
1. Define everything once not twice: It is a good idea to define your project
folder structure, the required libraries and other settings in one place. A simple
approach is a setup script, i.e. something like `course-name-provided-by-the-instructor_setup.R` that is sourced
into each control or analysis script of your project.
1. Use the same project folder structure in a team: Use the same folder structure
relative to a fixed starting point across all computers and devices of your team.
As a root folder, a folder in your home directory  (e.g. as described before `~/edu`) is the recommended choice.
Within this folder you can directly store your projects or use a symlink to any
other place on your storage devices.


### Special considerations at Marburg University computer labs
The R home directory on the computers in the labs at Marburg University points to
the network drive `H:/Documents`. For storage space reasons, you could not use
this drive for symlinks neither for the storage of the R-packages that you need to install. Therefore, you have to define an alternative starting point
for your project folders to work with.

To handle your project relative on all computers using something beneath your 
home directory `~` as a starting point except the
University computer labs, we therefore recommend to use the `envimaR` package.



### Conceptual Guideline
Again for the course it will be assumed that: 
* your local starting point is `~/edu`,
* your project is called `course-name-provided-by-the-instructor`,
* your git repository is called `course-name-provided-by-the-instructor`,
* your setup script is called `course-name-provided-by-the-instructor_setup.R` and is located at `course-name-provided-by-the-instructor/src`.


This setup is a bit more than a guideline, it is a rule. Read it, learn it, live it and have a nice ride.  
{: .notice--danger}

## Wrap it up in a setup script

Provided that I want to create a project with the mandantory folder structure defined above, check the PC that I am working on, load all packages that I need and store all of the environment variables in a list for later use, I may use the `createEnvi` function. 

Finally, we can initiate some useful settings. It makes sense to have the current Github versions of the non-CRAN packages installed on our systems and to set an option for temporary actions in the `raster` package.

If we put everything together in one script, it looks like this:


{% gist a2324e11b4342cbd4da29b0a819b58e6 %}

Note that installing the listed packages for the first time needs some time for execution.
If you encounter errors during this installation process, try to install the packages separately for making troubleshooting more convenient.
{: .notice--info}

Please *check* the result by navigating to the directory using your favorite file manger. In addition please check the returned `envrmt` list. It contains all of the paths as character strings in a convenient list structure.

```r
str(envrmt)
```

Again - For the course it is **mandantory** to save this script in the `src` folder named `course-name-provided-by-the-instructor_setup.R` and **source it always at the beginning** of each project start or at the start of an analysis or data processing script that is connected with this project. 
{: .notice--danger}

For your convenience you may use the following template for creating each new script.


<script src="https://gist.github.com/envimar/54c41da9a13146298ea42bffe942a933.js">notification</script>


Thus to summarize the above script:

- creates/initializes the mandatory basic folder structure 
- creates a list variable containing all paths as shortcuts  
- installs and initializes all packages and settings for the project



## Assignment Unit-1-1
Implement and check working environment setup

Set up and check the basic working environment as explained above.



### Concluding remarks 
Please note!

Several errors are likely to pop up during this installation and setup process. As you will learn through this entire process of patching together different pieces of software, some error warnings are more descriptive than others. 

This procedure is typical and usually necessary. For complex tasks, external software libraries and tools often need to be loaded and connected. Even if most software developers try to facilitate this to make it easier, it is often associated with an interactive and step-by-step approach.

When in doubt (**and before asking your instructor ;-)**), ask Google! Not because we are too lazy to answer (we will answer you, of course) but because part of becoming a (data) scientist is learning how to solve these problems. We all learned (and continue to learn) this way as well and it is highly unlikely that you are the first person to ask whatever question you may have -- Especially [StackOverflow](https://stackoverflow.com/questions/tagged/r) is your friend!




## Comments & Suggestions
