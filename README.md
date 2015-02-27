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

Here's another fine video guide I did. This one should have been short and sweet, but it wasn't either.

[![](https://raw.githubusercontent.com/kordless/swarm-ghost/master/assets/video.png)](https://vimeo.com/120735541)


### Code Checkout

Let's clone the repo:

    git clone https://github.com/kordless/swarm-ghost.git

Change into the directory:

	cd swarm-ghost

### Quick Launch

You can launch Ghost in by doing the following:

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

You will have needed to checkout the code in the **Code Checkout** section above.  Once you've done that, make sure you are in the directory:

	cd swarm-ghost

#### Giant Swarm and Docker Check
Let's make sure we're logged into Giant Swarm:

	swarm info
	
You'll get something along these lines:

```
superman:test-ghost kord$ swarm info
Cluster status:      reachable
Swarm CLI version:   0.15.0
Logged in as user:   kord
Current environment: kord/dev
```

If not, refer to [swarm-ngrok cookbook](https://github.com/kordless/swarm-ngrok#prerequisites) for more information on logging into Giant Swarm.

Now let's check Docker:

	docker version
	
You should see something like this:

```
superman:test-ghost kord$ docker version
Client version: 1.4.1
Client API version: 1.16
Go version (client): go1.3.3
Git commit (client): 5bc2ff8
OS/Arch (client): darwin/amd64
Server version: 1.5.0
Server API version: 1.17
Go version (server): go1.4.1
Git commit (server): a8a31ef
```

#### Build and Run Locally with Docker
Now let's build the Docker container locally **(don't forget the dot!)**:

	docker build -t registry.giantswarm.io/$(swarm user)/ghost .

Run that locally by doing the following:

	docker run -p 80:2368 -ti --rm registry.giantswarm.io/$(swarm user)/ghost
	
This will create a container that listens on port 80 on your **boot2docker** instance.  You can get the IP of the **boot2docker** instance by doing the following:

	boot2docker ip

That should produce something exactly like this, or worst case simlar to this:

	superman:test-ghost kord$ boot2docker ip
	192.168.59.103

Now pop that into your browser:

	http://192.168.59.103
	
You should get the sample blog post running in Ghost now.

#### Push to Giant Swarm

Now let's push the build to Giant Swarm!

	docker push registry.giantswarm.io/$(swarm user)/ghost
	
Finally, we tell Giant Swarm to bring up the project on their service:

	swarm up --var=username=$(swarm user)

We can check if it's running by doing a:

	swarm status
	
Remember, you need to be in the same directory as the project's ***swarm.json*** file!

**Note the instance ID and copy it.**

```
superman:test-ghost kord$ swarm status
App ghost is up

service        component  image                              instanceid                            created              status
ghost-service  ghost      registry.giantswarm.io/kord/ghost  8685ae85-fb19-46eb-b980-35fcd9bac348  2015-02-26 19:14:59  up
```

Now take a look at the logs of the application by doing a:

	swarm logs 8685ae85-fb19-46eb-b980-35fcd9bac348
	
Remember, you'll need to use the instance ID you found in the status output!

#### Access Ghost
Once again, check your Giant Swarm username:

	superman:shellinabox kord$ swarm info |grep user
	Logged in as user:   kord

Now build a URL that uses that username **(note you need to use your username here)**:

	http://ghost-kord.gigantic.io
	
Finally, configure your blog for use **(note you need to use your username here)**:

	http://ghost-kord.gigantic.io/ghost/

#### Custom Domains
If you want to use a custom domain for your blog, you'll need to create a CNAME entry for your domain on your DNS provider.  It should look something like this:

```
CNAME	ghost.geekceo.com	3600		loadbalancer.gigantic.io
```

One you've made those changes (and you may have to wait a bit for that to take affect) you can change the 'domains' entry in the **swarm.json** file to point Giant Swarm's loadbalancer to the correct app for your particular FQDN:

Here's an example:
```
{
  "app_name": "ghost",
  "services": [
    {
      "service_name": "ghost-service",
      "components": [
        {
          "component_name": "ghost",
          "image": "registry.giantswarm.io/$username/ghost",
          "ports": [2368],
          "domains": { "ghost.geekceo.com": 2368 }
        }
      ]
    }
  ]
}
```

That's it!  Here's to you starting to write a blog post! :beer: 


