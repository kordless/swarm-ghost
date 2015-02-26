## Swarming Ghost
Interested in deploying your own blog on the Ghost blogging platform?  How about doing that at warp speed?

![engage](https://raw.githubusercontent.com/kordless/swarm-ghost/master/assets/meme.jpg)

### Prerequisites

The [standard prerequisites](https://github.com/kordless/swarm-ngrok#prerequisites) apply to this project. At a minimum you need the following:

* A Giant Swarm [account](https://giantswarm.io).
* The **swarm** command line client [installed](http://docs.giantswarm.io/reference/installation/).
* A functional install of [boot2docker](https://github.com/kordless/boot2docker-ing).

The [swarm-ngrok cookbook](https://github.com/kordless/swarm-ngrok#prerequisites) has more details on fulfilling the prerequisites, if you get stuck.

### Video Walkthrough

Here's another fine video guide I did. This one should be short and sweet.

[![](https://raw.githubusercontent.com/kordless/swarm-ghost/master/assets/video.png)](https://vimeo.com/120117064)


### Quick Launch

You can launch Ghost in under a minute and a half by doing the following:

    git clone https://github.com/kordless/swarm-ghost.git

Change into the directory:

	cd swarm-ghost

There's nothing left to do but push that shizzle to Giant Swarm:

    make swarm-up

Check your Giant Swarm username:

	superman:shellinabox kord$ swarm info |grep user
	Logged in as user:   kord

Now build a URL that uses that username **(note you need to use your username here)**:

	http://ghost-kord.gigantic.io
	
Finally, configure your blog for use **(note you need to use your username here)**:

	http://ghost-kord.gigantic.io/ghost/

### One Step at a Time Install

