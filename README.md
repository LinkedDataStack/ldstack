ldstack
=======

A debian package to register the Linked Data Stack repository on a Ubuntu system.


This keyring is used as a trusted keyring for the LinkdeData package
repository.

to modify the pubring.gpg try:

    gpg --homedir ./ --import xxx.asc
    (add a new maintainer key)
or

    gpg --homedir ./ --delete-key F27A1C8B
    (remove an old maintainer key)
in this directory.

after that, create a new package with

    make ldrepository

Workplan for key changes:

1. checkout / update this directory
2. add or replace a key under ./keys
   - *.asc are gpg keys (signing)
   - *.pub are ssh keys (dput)
3a. in case of ssh key changes:
   - run "make upload-keys"
3b. in case of gpg key changes:
   - add the key.asc to the database (e.g. gpg --homedir ./ --import keys/X.asc)
   - create a new package (make ldrepository)
   - upload it with dput
4. svn commit the changes


-------------------------
For the lod2 repositories:

There are 3 versions, all reprepro based
* the nightly build version: lod2repository
* the testing version: lod2testing-repository
* the stable version: lod2stable-repository
