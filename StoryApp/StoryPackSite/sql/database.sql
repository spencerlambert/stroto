CREATE DATABASE story_packs;

CREATE TABLE `Version` (
    `Version`           varchar(15)
);

CREATE TABLE `StoryPack` (
    `StoryPackID`       int(10) NOT NULL AUTO_INCREMENT,
    `Name`              varchar(100),
    `Description`       text,
    `ThumbnailURL`      varchar(100),
    `Type`              enum('Free','Paid'),
    `CategoryOne`       enum('Featured','Storybooks','Animals','People'),
    `CategoryTwo`       enum('Featured','Storybooks','Animals','People'),
    `DisplayOrder`      int(10) default 100,
    `Price`             float(6,2),
    `AppleStoreKey`     varchar(100),
    PRIMARY KEY (`StoryPackID`)
);

CREATE TABLE `Images` (
    `ImageID`           int(10) NOT NULL AUTO_INCREMENT,
    `StoryPackID`       int(10),
    `ImageDataPNG`      longblob,
    `ImageType`         enum('Background','Foreground'),
    `DefaultScale`      float(4,3),
    `ThumbnailURL`      varchar(100),
    PRIMARY KEY (`ImageID),
    KEY (`StoryPackID`)
);

CREATE TABLE `Purchase` (
    `PurchaseID`        int(10) NOT NULL AUTO_INCREMENT,
    `StoryPackID`       int(10),
    `Price`             float(6,2),
    `AppleReceipt`      varchar(100),
    `AppleUser`         varchar(100),
    `Valid`             enum('Yes','No'),
    `PurchaseDate`      timestamp NOT NULL,
    PRIMARY KEY (`PurchaseID`),
    KEY (`StoryPackID`),
    KEY (`PurchaseDate`)
);
