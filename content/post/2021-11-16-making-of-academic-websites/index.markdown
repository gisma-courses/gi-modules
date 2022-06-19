---
title: Academic writing made easy
author: Chris Reudenbach
date: '2021-11-16'
slug: []
categories: ["scidoc"]
tags: ["reproducibility","project management","Rmarkdown"]
description: 'The blogdown package provides a fully functional blogging tool from setting up websites to editing and discussing content. It is abel to handle both  markdown and R markdown content. The chosen hugo-theme-minima-gisma theme is a slightly adapted version of the hugo-theme-minima.It provides basic functionality and an incredible straightforward design.'
image: '/assets/images/head-assign.jpg'
toc: yes
output:
  blogdown::html_page:
    keep_md: yes
weight: 210
---

## Setting up the blogdown Project

We will use blogdown as an incredible easy to use an effiecient tool for setting up websites and producing content. First you need to install the neccessary packages:

``` r
# Install blogdown 
install.packages("blogdown")
# Install the "hugo" website framework
blogdown::install_hugo(force = TRUE)
library(blogdown)
```

To initialize a blogdown website I strongly recommend to use the menu bar of RStudio.

-   `RStudio toolbar -> File -> New Project -> New Directory -> blogdown website`
-   Copy `gisma-courses/hugo-theme-cleanwhite-gc` into the Hugo theme field
-   activate `Open in new session`
-   Click on `Create Project`

After some seconds you will see the new website project.

![folder of website](images/folder.png)

Basically all content is placed in the `content` folder and all resources that you want to serve manually, is put under the `static` folder.

Please **first** check if the `Git` tab is already visible. If so, please navigate to `Project Options -> Git/SVN` and set `Version control systems` to `none`. this will avoid later hazzles.

### Mandatory Adaptions

You must once open the `config.yaml` file which is located in the root folder of the new course and adapt at least `title`, `URL` and `publishDir`. This settings are found at the beginning of the yaml file:

``` r
baseurl: https://your-github-name.github.io/your-repo-name # Website URL
publishDir: docs
title: name-of-my-blog  # Website Name 
```

Now please delete the folder `public`

### Build the pages

Now build the site for publishing.

``` r
blogdown::build_site(build_rmd = TRUE)
# for singele pages you may use 
blogdown::build_site(build_rmd = "page-name")
```

The argument `build_rmd = TRUE` **forces** a rebuild of all Rmarkdown files.

{{% alert "Warning" "warning" "black" "black" "Please keep in mind that you must rebuilt your pages ALWAYS before pushing them  to GitHub" %}}

### Serve the site locally

With `blogdown::build_serve()` you start the local server and the compiled site is shown in the viewer pane. Alternatively you may also use the GUI via `RStudio toolbar -> Serve -> Addins -> Serve Site`.

Basically you start serving the website on localhost (means on the web-server as provided by RStudio). You notice that the site is visualized in the viewer pane. You easily can shift the view to your default browser by clicking on the symbol next right to the cleaning brush.

{{% alert "Hint" "info" "black" "black" "Sometimes after the rebuild of the site it is neccessary to restart the rsession. You may use Ctrl+Shift+F10. After that you must restart the local server using the above command." %}}

## Setting up the version control

Up to now you are fine with a locally running website for ducumentation purposes. To get it on air you need to push this whole site to a GitHub repository. So you need to do the following steps:
2. Initialize Git localy
2. Setup Git for Rstudio
3. Setup git for Rstudio
2. Mark (track) and commit all files in the project
2. Set up the corresponding GitHub repository and push the files

Step 4 and 5 are the typical steps running a version control system

### Initialize Git

Now we can set up version control and GitHub connections. Navigate to:

`RStudio toolbar -> Tools -> Project Options -> Version Control -> select git`
and confirm your choice. You notice that the Git tab is included now.

### Setup git for Rstudio (if not already done)

Use your GitHub credentials.

``` r
git config --global user.email "your-name@your.email"
git config --global user.name "your github name"
```

### Track all project files.

*Solution 1: *
Tick all files in the git pane of RStudio -\> click on `Commit` add “**First commit**” in the text field and click again on `commit`.

*Solution 2: *
switch to the terminal tab (beside the console tab) and type:
- `git add --all`
- `git commit -m "First commit"`

### Setting up the corresponding GitHub repository

1.  Create a new repository on your GitHub account **without adding anything**
2.  Link your local repo to remote repo by switching back to the terminal tab and type:

``` bash
git remote add origin https://github.com/gisma-courses/myBlog.git

# please note due tu inlusion codex Github is changing the default branch name from master to main so please check and adapt
git push -u origin main

```

You obviously Have to sign in with either a webbased login or with your token.

### If you want - publish your Website on Github

1.  Navigate on GitHub to `Repository -> Settings -> Pages`
2.  Select `Source -> Master Branch`
3.  Select `Folder -> /docs`
4.  `Save`

You will get a message like:

{{% alert "" "info" "black" "black" "Your site is ready to be published at https://gisma-courses.github.io/myBlog/" %}}

If everything is fine it will switch over to green (takes some minutes).

{{% alert "" "success" "black" "black" "Your site is ready to be published at https://gisma-courses.github.io/myBlog/" %}}

### GitHub Pitfalls

For windows it is assumed that you use the [current client](https://git-scm.com/download/win). It is strongly suggested to use [`notepad++`](https://notepad-plus-plus.org/) as editor which will be asked to choose during installation. To initialize this version of ``` git`` with ```RStudio``` you need to navigate  to ``Tools->Global Options->Git/SVN ``` tick `Enable version control interface for RStudio projects` and navigate to the `Git executables` which is commonly found under `C:/Program Files/Git/bin/git.exe`.

{{% alert "Note" "warning" "black" "black" "There are a lot of possible pitfalls using git with RStudio especially with Windows. If so please use the comments to address them. " %}}

{{% alert "Warning" "danger" "black" "black" "I strongly suggest to Use only Rstudio for pushing and pulling in your blogdown project." %}}

## Adding Content

After successfully setting up the blogdown website and connecting it to gihub for version control and publishing, the next task is obviuosly to produce content - e.g. the exercises.

The handling is very simple and clearly organised. Even though everything can be done via the command line, I recommend using the addins menu:

`Addins -> New Post`

You start the common GUI for creating a so called *post* which means an article for your website.

![interface newpost](images/newpost.png)

-   The `title` is self-explanatory.
-   `Author` and `Date` are entered automatically, but can be changed.
-   The `subdirectory` should also remain at default (`post`).
-   `Categories`, `Tags` and `Archetypes` shape the navigation and organisational structure and they are crucial.
    -   `Categories` can be freely assigned. However, it should be noted that they are automatically listed in the menu under the Menu Categories in order to structure the blogs. This also applies to the `Tags`. I suggest always using the same category for this course (e.g. `aGIS`) and using `Exercises` as Tag for exercises. Each typing error will of course be converted into its own tag or category.
-   There are templates, the so-called `Archetypes` from which you should used `sci-report.md` for all exercises if not otherwise stated.
-   The last step is to select the `Format`. For all R-related content, I highly recommend selecting `Rmarkdown`.

After clicking `Done` you have generated your new article with some structural information and in addition some hints how to deal with R-commands. Please delete this exemplary content when you edit this file. If you are finished you easily can use the RStudio Git MEnu to Commit and Push the content to GitHub.

If you want to add images etc. you should use the corresponding `Menu->Addins->Insert Image` workflow.

## Wrap up

After these steps and adjustments you have a fully functional blogging website that translates both Markdown and Rmarkdown content and makes it available as web content. The choosen hugo-theme-minima-gisma theme is a slightly adapted from the hugo-theme-minima theme. It provides templates for dealing with the assesments.

Of course you are welcome to choose other themes. There are [countless](https://bookdown.org/yihui/blogdown/other-themes.html). However, you should make sure that they offer Rmarkdown support.

## Comments & Suggestions
