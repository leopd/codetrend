# CodeTrend

This is a public open service for comparing trends in software technologies.

It is available for public use at http://www.codetrend.org/

Currently it only uses StackExchange data, but in the future I envision it pulling additional
signals like google trends, ohloh, github, tiobe.

Moreover, since these comparisons are so subjective, I'd like to see this site
be a place where people can express their opinions comparing competing technologies.
If we provide a medium for these opinions that can aggregate them intelligently,
then we will have a truly useful and self-supporting resource.

## Contributions

Want to help out?  Fork the code at https://github.com/leopd/codetrend and send a submission.
Or contact Leo directly: http://leodirac.com/contact


## Re-building the dataset

First download the most recent SO data dump from http://www.clearbits.net/creators/146-stack-exchange-data-dump
This involves torrenting, and then recombining all the stackoverflow.com 7zip files.  

Once you have the stackoverflow Posts.xml file reconstructed, you need to run some `rake` commands:

    rake db:mongoid:create_indexes
    rake datadump:load FILENAME=../path/to/stackoverflow/Posts.xml DATASET=stackoverflow-posts
    rake datadump:create_all_technologies

Note that these commands can take hours even on a fast machine.  
Feel free to dive into the `TODO` comments to speed them up.

