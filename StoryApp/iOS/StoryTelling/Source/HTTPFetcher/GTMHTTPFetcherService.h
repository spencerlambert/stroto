/* Copyright (c) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTMHTTPFetcherService.h
//

// The fetcher service class maintains a history to be used by a sequence
// of fetchers objects generated by the service.
//
// Fetchers that do not need to share a history may be generated independently,
// like
//
//   GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
//
// Fetchers that should share cookies or an ETagged data cache should be
// generated by a common GTMHTTPFetcherService instance, like
//
//   GTMHTTPFetcherService *myFetcherService = [[GTMHTTPFetcherService alloc] init];
//   GTMHTTPFetcher* myFirstFetcher = [myFetcherService fetcherWithRequest:request1];
//   GTMHTTPFetcher* mySecondFetcher = [myFetcherService fetcherWithRequest:request2];

#import "GTMHTTPFetcher.h"
#import "GTMHTTPFetchHistory.h"

@interface GTMHTTPFetcherService : NSObject<GTMHTTPFetcherServiceProtocol> {
 @private
  NSMutableDictionary *delayedHosts_;
  NSMutableDictionary *runningHosts_;
  NSUInteger maxRunningFetchersPerHost_;

  GTMHTTPFetchHistory *fetchHistory_;
  NSOperationQueue *delegateQueue_;
  NSArray *runLoopModes_;
  NSString *userAgent_;
  NSTimeInterval timeout_;
  NSURLCredential *credential_;       // username & password
  NSURLCredential *proxyCredential_;  // credential supplied to proxy servers
  NSInteger cookieStorageMethod_;

  BOOL shouldFetchInBackground_;

  id <GTMFetcherAuthorizationProtocol> authorizer_;
}

// Create a fetcher
//
// These methods will return an autoreleased fetcher, but if
// the fetcher is successfully created, the connection will retain the
// fetcher for the life of the connection as well. So the caller doesn't have
// to retain the fetcher explicitly unless they want to be able to monitor
// or cancel it.
- (GTMHTTPFetcher *)fetcherWithRequest:(NSURLRequest *)request;
- (GTMHTTPFetcher *)fetcherWithURL:(NSURL *)requestURL;
- (GTMHTTPFetcher *)fetcherWithURLString:(NSString *)requestURLString;
- (id)fetcherWithRequest:(NSURLRequest *)request
            fetcherClass:(Class)fetcherClass;

// Queues of delayed and running fetchers. Each dictionary contains arrays
// of fetchers, keyed by host
//
// A max value of 0 means no fetchers should be delayed.
//
// The default limit is 10 simultaneous fetchers targeting each host.
@property (assign) NSUInteger maxRunningFetchersPerHost;
@property (retain, readonly) NSDictionary *delayedHosts;
@property (retain, readonly) NSDictionary *runningHosts;

- (BOOL)isDelayingFetcher:(GTMHTTPFetcher *)fetcher;

- (NSUInteger)numberOfFetchers;        // running + delayed fetchers
- (NSUInteger)numberOfRunningFetchers;
- (NSUInteger)numberOfDelayedFetchers;

// Search for running or delayed fetchers with the specified URL.
//
// Returns an array of fetcher objects found, or nil if none found.
- (NSArray *)issuedFetchersWithRequestURL:(NSURL *)requestURL;

- (void)stopAllFetchers;

// Properties to be applied to each fetcher;
// see GTMHTTPFetcher.h for descriptions
@property (copy) NSString *userAgent;
@property (assign) NSTimeInterval timeout;
@property (retain) NSOperationQueue *delegateQueue;
@property (retain) NSArray *runLoopModes;
@property (retain) NSURLCredential *credential;
@property (retain) NSURLCredential *proxyCredential;
@property (assign) BOOL shouldFetchInBackground;

// Fetch history
@property (retain) GTMHTTPFetchHistory *fetchHistory;

@property (assign) NSInteger cookieStorageMethod;
@property (assign) BOOL shouldRememberETags;      // default: NO
@property (assign) BOOL shouldCacheETaggedData;   // default: NO

- (void)clearETaggedDataCache;
- (void)clearHistory;

@property (nonatomic, retain) id <GTMFetcherAuthorizationProtocol> authorizer;

// Spin the run loop, discarding events, until all running and delayed fetchers
// have completed
//
// This is only for use in testing or in tools without a user interface.
//
// Synchronous fetches should never be done by shipping apps; they are
// sufficient reason for rejection from the app store.
- (void)waitForCompletionOfAllFetchersWithTimeout:(NSTimeInterval)timeoutInSeconds;

@end
