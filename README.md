#Database models test - iOS
>A project to compare performance of Magical record (Wrapper around core data) and Realm database model

Below are some of statistics of the comparison between Realm and Core data model for database containing few thousand records. Performance is computed is terms of Create, Delete and Read operations. (Execution times are taken by running tests multiple times. Figures explained below however represent execution time for one of those program runs)

**These performance figures are as follows :**
___
- Performance details of Airlines Records retrieved using FlightStats API (Total 1920 Records) - Network latency was 0.000045 seconds. P.S. All the following figures are in Seconds unit.

| Operation | Core Data (Magical record)  | Realm  | Ratio(Core Data/Realm) | Winner
|:---|:---:|---:|---:|---:|
| Read  |  0.001024  | 0.000025  | 40.96 | Realm
| Create  | 0.007469  | 0.017996  | 0.415 | Core Data
| Delete  | 0.001422 | 0.000767 | 1.85 | Realm
| Read With Predicate | 0.001982 | 0.000199 | 10 | Realm  

___

 - Performance details of Airport Records retrieved using FlightStats API (Total 16126 Records) - Network latency was 17.127410 seconds. 

| Operation | Core Data (Magical record)  | Realm  | Ratio(Core Data/Realm) | Winner
|:---|:---:|---:| ---:| ---:|
| Read  |  0.005375  | 0.000042  | 128 | Realm
| Create  | 0.092580  | 0.230939  | 0.4 | Core Data
| Delete  | 0.001422 | 0.000767 | 1.85 | Realm
| Read With Predicate | 0.011655 | 0.001864 | 6.25 | Realm  

It seems for above comparison that, except for creating new database objects, where Core data performs better than Realm data model it seems that in all the remaining categories Realm prevails Core Data in terms of execution time.

In addition to it, Realm data model is easier to setup compared to pain when setting up pure Core data model and Magical Records wrapper around Core data implementation.

***
###Imp : End of Database models comparison statistics
##Relationship models using Realm

_Demonstration of relationships for Realm data model :_

This is off the topic in comparison to what I decided to write about earlier. However, I always felt uncomfortable dealing with one-to-many relationships in database models representation. Following text explains how to set up and verify one to many relationships using Realm data model. All the information is inherited from official Realm page at http://realm.io/docs/cocoa.


Relationship is explained with very simple example between Developer and ReleasedApp models. As name suggests, Developer represents regular developer object where ReleasedApp represents the details of app published by that developer. For simplicity, we will assume one to many relationship from Developer to ReleasedApp. In other words, one Developer can release multiple apps, but single app cannot be released by multiple developers

Developer model is as follows : 

```
@interface Developer : RLMObject
@property NSString* name;
@property NSString* platform;
@property NSString* experience;
@property NSString* state;
@property RLMArray<ReleasedApp> *releasedAppsCollection;
@end
```

Property, 
```
RLMArray<ReleasedApp> *releasedAppsCollection;
```
Represents the Realm array data type RLMArray which indicates collection of ReleasedApp objects as a part of one-to-many relationship

Similarly,
ReleasedApp model is defined as follows : 
```
@interface ReleasedApp : RLMObject
@property NSString* appName;
@property NSString* cost;
@property NSString* platform;
@end
RLM_ARRAY_TYPE(ReleasedApp)
```
where
```
RLM_ARRAY_TYPE(ReleasedApp)
```
Indicates that model ReleasedApp will act as a part of array collection for Developer object. i.e. Developer model will hold an array which will contain objects of type ReleasedApp

Now, let's create a Developer object as follows

```
//Get default instance of Realm,
RLMRealm* defaultRealm = [RLMRealm defaultRealm];
Developer* developerObject = [[Developer alloc] init];
developerObject.name = @"Bob";
developerObject.platform = @"iOS";
developerObject.state = @"California";
developerObject.experience = @"2";
//Write operation must be performed in beginWrite and commitWrite transaction blocks. Not doing so will result in RLMException
[defaultRealm beginWriteTransaction];
[defaultRealm addObject:developerObject];
[defaultRealm commitWriteTransaction];
```

Now let's create a newAppToAdd object which will be linked to the developerObject object we just created. It also means that developerObject has newAppToAdd object, or in other words, newAppToAdd belongs to developerObject.

```
ReleasedApp* newAppToAdd = [[ReleasedApp alloc] init];
newAppToAdd.appName = @"My Awesome app";
newAppToAdd.cost = @"0";
newAppToAdd.platform = @"iOS";
[defaultRealm beginWriteTransaction];
[developerObject.releasedAppsCollection addObject:newAppToAdd];
[defaultRealm commitWriteTransaction];
```
Now we have created new Developer and ReleasedApp objects and linked them together. In the similar fashion we can also create many ReleasedApp instances and link them to developerObject instance.

When we do, 
```
RLMArray* appForDeveloper = [developerObject releasedAppsCollection];
```
We will get collection of all apps associated with that developer.











