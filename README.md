## Swarming Ghost
Interested in deploying your own blog on the [Ghost](http:ghost.org) blogging platform?  How about doing that at warp speed with [Giant Swarm](http://giantswarm.io/)? Here's a [quick demo site](http://kord.playground.giantswarm.io/hello/).

![engage](https://raw.githubusercontent.com/kordless/swarm-ghost/master/assets/meme.jpg)

***Engage.*** - Jean-Luc Picard

### Prerequisites

The [standard prerequisites](https://github.com/kordless/swarm-ngrok#prerequisites) apply to this project. At a minimum you need the following:

* A Giant Swarm [account](https://giantswarm.io).
* The **swarm** command line client [installed](http://docs.giantswarm.io/reference/installation/).
* A functional install of [boot2docker](https://github.com/kordless/boot2docker-ing).
* An [Amazon AWS account](http://aws.amazon.com/) to use for backups.

The [swarm-ngrok cookbook](https://github.com/kordless/swarm-ngrok#prerequisites) has more details on fulfilling the prerequisites for Giant Swarm stuff, if you get stuck.

### Video Walkthrough

Here's another fine video guide I did, but which is a little out of date. If you want backups working, you'll need to run the examples below.  I'll have a new video up shortly.

[![](https://raw.githubusercontent.com/kordless/swarm-ghost/master/assets/video.png)](https://vimeo.com/120735541)


#### Code Checkout
Let's clone the repo:

    git clone https://github.com/giantswarm/blog.git

Change into the directory:

	cd blog

### Quick Launch

If you are cool without backups, you can launch Ghost by pushing it to Giant Swarm:

    make swarm-up

The *Makefile* will output your blog's URL and admin URL. That's seriously all you have to do.

### One Step at a Time Install

You will have needed to checkout the code in the **Code Checkout** section above.  Once you've done that, make sure you are in the directory:

	cd swarm-ghost

#### Backups
Backups run from a cronjob on the Ghost container every 12 hours. The cronjob will zip up the mysql database and upload it to your S3 bucket. If you want to change the default backup schedule, you can edit the **cron.conf** file before deploying:

	0 0,12 * * * /ghost/backup.sh

Here's a crontab file [reference](http://www.adminschoice.com/crontab-quick-reference).

#### AWS Setup
To start, you'll need to create a new user in your AWS account.  To start, navigate to the [AWS Console](https://console.aws.amazon.com/) and then follow these steps:

1. Click on the **Identity & Access Managment** icon/link (it's a green key in the middle).
2. Click on **users** in the left navigation panel.
3. Click on the **create new users** button at the top.
4. Enter a username called **ghost-backups** and click **create** down at the bottom right.
5. Click **show user security credentials** at the top, or **download credentials** at the bottom.
6. Copy (or save) the credentials somewhere you can get at them later.
7. Click **close** at the bottom right twice.
8. Click on **users** in the left navigation panel and then click on the new user's name.
9. Copy the User ARN at the top. You'll use this in a minute to build an access policy.

Now navigate to the [AWS S3 dashbord](https://console.aws.amazon.com/s3/) and then follow these steps to allow the backup user to access the bucket:

1. Click on the **create bucket** button.
2. Enter a bucket name like *giantghost-kord* and pick a region to store the bucket.
3. Click on the bucket name in the list to view the bucket.
4. Click on the **actions** pulldown at the top and select **create folder**.
5. Name the folder **backups** and hit enter.
6. Click **All Buckets** and then select the bucket you created above.
7. Click on the **properties** tab/button at the top right.
8. Click on **permissions** in the list.
9. Click **Edit Bucket Policy** and enter use the following as a *guide*:

```
{
	"Version": "2015-10-29",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::917652411881:user/ghost-backups"
			},
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::giantghost-kord/backups"
		}
	]
}
```

Remember, subsititue the Principal's AWS string with the ARN you got from step #8 above and then change the end of the bucket *Resource* text to use your bucket name instead of *giantghost-kord*.  Click the **save** button on the dialog to save your changes to the policy.

***Note: I tried to find a way to tell you how to locate the bucket's ARN, but failed. Just be careful hacking it up there and you'll be fine!***

#### Mailgun Setup
Navigate to [Mailgun](https://mailgun.com) and either create an account or login to your existing account and go grab your Mailgun API key.  You'll use it and your Mailgun email address in the Makefile below.

#### Edit the Makefile
Now you'll need to edit the existing Makefile with your settings gathered above (these are older deleted keys I'm using):

```
# AWS auth and bucket info
AWS_ACCESS_KEY_ID=AKIAIWC5LPPK3PYWKBLQ
AWS_SECRET_ACCESS_KEY=0Jnr4+Mp4Qqi9kh8RNw+V0Vn5CoJYnX7euiqFj+E
AWS_DEFAULT_REGION=eu-central-1
S3_BUCKET=giantghost-$(shell swarm user)/backups

# mailgun stuff
MAILGUN_USERNAME=kordless@foobar.com
MAILGUN_APIKEY=144f29d23ffab65fd41afc18424d544c

# mysql stuff
MYSQL_USERNAME=root
MYSQL_PASSWORD=f00bar
MYSQL_DATABASE=ghost

# domain settings
HOSTNAME=$(USERNAME).playground.giantswarm.io
CNAME=$(HOSTNAME)
DEV_HOSTNAME=$(shell boot2docker ip):2368
DEV_CNAME=$(DEV_HOSTNAME)
```

Make the following edits to the Makefile:

1. Change the *AWS_ACCESS_KEY_ID* and *AWS_SECRET_ACCESS_KEY* to whatever you copied from AWS.
2. Change the *AWS_DEFAULT_REGION*. Here's a [list of regions](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).
3. Change the *S3_BUCKET* to whatever your bucket is + **/backups** onto the end of it.
4. Change the *MAILGUN_USERNAME* to your Mailgun account's email address.
5. Change the MAILGUN_APIKEY to your Mailgun account's API Key (less the 'key-' part)
4. Make sure you don't have any spaces ***before or after*** any of the variables!

If you want to use a custom domain for your blog, scroll to the bottom of this guide.


#### Blog Recovery
To recover the blog from S3 backups, go to the directory in the your bucket and navigate to the year, month and day of the backup you would like to restore. There are two files which are used to do the recovery (using examples):

* ```mysql_2015-04-23_21-04.sql.gz``` - mysql database dump 
* ```content_images_2015-04-23_21-04.tar.gz``` - zipped directory of all images uploaded to blog

##### Images to Ghost Container
To recover the images to the blog container, you'll need to download the content images tar file and unzip it. Take the contents of the ```/ghost-override/content/images/``` directory and place them in the ```/ghost-files/content/images/``` directory in the blog repo directory.  The **.gitignore** file is set to ignore these files, in case you are doing development on the repo.

##### Database Recovery
To recover the backup to repopulate the database, copy the mysql zipped file to the ```/ghost-files/``` directory and rename it to ```blog.sql``` so it will be copied into the container by docker:

	gunzip mysql_2015-04-23_21-04.sql.gz 
	mv mysql*.sql ~/blog/ghost-files/blog.sql
    
Note the filename needs to be ```mysql.sql``` in order for the ```start.sh``` script to see it and push it to the mysql container.

Again, **.gitignore** is set to ignore this file.

You may then deploy the recovered blog by doing a:

    make swarm-up

Or, alternately, if you already have it running:

	make docker-push
	swarm update ghost-blog/server/ghost

As soon as you have verified the database has been restored (by using the site), you need to remove the backup file from your local copy and push the changes to the index again:

    rm ghost-files/ghost.sql
    make docker-push
	swarm update ghost-blog/server/ghost

See below for more information on pushing and accessing the deployment.

#### Giant Swarm and Docker Check (No Backups Skip to Here)
Now all that mess is out of the way, let's make sure we're logged into Giant Swarm:

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
To run locally, you'll need to start the MySQL container first:

	make docker-mysql
	
That should start and exit back to the prompt.  Next, start the Ghost container:

	make docker-run
	
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
The **Makefile** should output your domain.  If you like, you can build it manually. Start by checking your Giant Swarm username:

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

One you've made those changes (and you may have to wait a bit for that to take effect) you can change the **DOMAINS** entry in the **Makefile** file:

Here's an example:

```
DOMAIN=ghost.geekceo.com
```

That's it!  Here's to you starting to write a blog post! :beer: 

#### Other Backups
[Here's a nice guide](http://blog.samhutchings.co/lets-zap-some-ghosts/) to auto backing up Ghost to Dropbox.

