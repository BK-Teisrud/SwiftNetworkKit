# Test declaration inventory — BUG-01

Snapshot: 2026-10-26, BUG-01 candidate based on `5ea73b3f8f4045bea23dd32bd0b8b3273c2a9358`. This source index contains 216 `@Test` function declarations, including two macOS-only child-process tests; other selected runtime destinations retain 214 declarations. Parameterized cases are not additional function declarations. Runtime results must come from execution, not this count. See [contract evidence ledger](TEST_EVIDENCE.md) for coverage and limitations. Refresh this snapshot when the suite changes; historical run counts remain dated evidence.

## AuthenticationTests.swift

[Source](../../Tests/NetworkKitTests/AuthenticationTests.swift) — 15 declarations.

- `bothInputsReceiveMinimalContextAndHeaders`
- `credentialConflictsAreNeverSilentlyOverwritten`
- `providerFieldsCannotBypassValidation`
- `httpNeverInvokesProvider`
- `additionalOriginsNeverInheritProviderOrDefaults`
- `optOutSkipsOnlyProviderAndRetainsExplicitPrecedence`
- `providerFailuresAreSafeAndNeverReachTransport`
- `providerSharesCancellationBudgetAndJoinedCleanup`
- `concurrentAccountsUseIndependentBindingsAndRequestIdentifiers`
- `cancellingOneAccountLeavesOtherProviderWorkAlive`
- `responsesDoNotRefreshOrReplay`
- `authDescriptionsExcludeAccountEnvironmentAndCredentials`
- `preCancelledCallNeverInvokesProvider`
- `invalidRequestsNeverInvokeProvider`
- `redirectCannotMoveProviderCredentialsToAnotherOrigin`

## ClientLifecycleTests.swift

[Source](../../Tests/NetworkKitTests/ClientLifecycleTests.swift) — 11 declarations.

- `shutdownWithoutActiveWorkIsIdempotent`
- `closingRejectsBothInputsBeforeReadingOptionsAndJoinsCleanup`
- `concurrentShutdownRetainsCleanupOwnership`
- `shutdownWaitsForTransportFinalization`
- `admissionRemembersShutdownBeforeOperationBinding`
- `firstTimeoutOrShutdownCauseIsPreserved`
- `selectedCompletionSurvivesShutdown`
- `concurrentClientCallsKeepSnapshotsAndCodecsIndependent`
- `failedCallsReleaseAdmissionBeforeShutdown`
- `ownedSessionIsClosedAfterItsOperationsJoin`
- `borrowedSessionKeepsAnotherClientsActiveWorkAlive`

## ConfigurationTests.swift

[Source](../../Tests/NetworkKitTests/ConfigurationTests.swift) — 8 declarations.

- `defaultsAndIndependentOverrides`
- `invalidLimits`
- `positiveFiniteLimits`
- `concurrentSnapshotsAreIndependent`
- `descriptionsExcludeConfigurationSecrets`
- `scriptedTransportWithoutNetworking`
- `monotonicDeadlineWithoutWaiting`
- `productionClockCancellation`

## DiagnosticsTests.swift

[Source](../../Tests/NetworkKitTests/DiagnosticsTests.swift) — 13 declarations.

- `canariesInEveryBoundaryStayOutOfEventsAndErrorDescriptions`
- `onlyExactAllowlistedMethodNamesAreRetained`
- `enablingAndDisablingPreservesResultsAndRequests`
- `loggingDoesNotReadEndpointPropertiesOrDescriptionsAgain`
- `rejectedAdmissionAndPreCancellationEmitOneSafeEvent`
- `eventWaitsForJoinedCleanupAndIncludesItsDuration`
- `sinkLatencyCannotRewriteSelectedResultOrMeasuredDuration`
- `cancellationCategoriesFollowTheSelectedCause`
- `firstCancellationCauseSurvivesTheLaterCause`
- `selectedCompletionSurvivesLateCancellation`
- `timeoutsRemainCategorizedWithoutPendingDiagnosticsWork`
- `concurrentAccountsProduceOnlyIndependentSanitizedTerminalEvents`
- `unknownErrorsAreClassifiedWithoutFormattingThem`

## DocumentationExamplesTests.swift

[Source](../../Tests/NetworkKitTests/DocumentationExamplesTests.swift) — 4 declarations.

- `typedGuideDecodesValueAndMetadata`
- `formatGuideHandlesBytesTextEmptyAndExplicitStatus`
- `ownershipGuideConstructsAndClosesBothProfiles`
- `authAndErrorGuideUsesPublicBoundariesWithoutNetworking`

## EndpointURLTests.swift

[Source](../../Tests/NetworkKitTests/EndpointURLTests.swift) — 15 declarations.

- `typedEndpointAndBasePath`
- `reservedAndUnicodeSegmentsAreData`
- `queryOrderingRepetitionsAndOptionalValues`
- `invalidSegments`
- `asciiEscapingAndControlValidation`
- `invalidBaseURLs`
- `relativeURLWithFoundationBaseIsRejected`
- `snapshotsKeepTheirOwnPathAndQuery`
- `existingEscapesStayEncodedOnce`
- `safeDescriptionsAndErrors`
- `validSameOriginRequestPreservesURL`
- `invalidRequestsUseSameValidation`
- `missingURLAndInvalidBaseAreRejected`
- `unicodeHostAndEffectivePorts`
- `typedURLPassesRawValidation`

## F1AcceptanceTests.swift

[Source](../../Tests/NetworkKitTests/F1AcceptanceTests.swift) — 6 declarations.

- `typedAndRawPOSTHaveRequestAndResponseParity`
- `encodingFailureDoesNotSendOrPoisonClient`
- `HTTPFailurePrecedesDecoderWithoutRetry`
- `invalidUTF8IsDecodingFailureForBothInputs`
- `extraRawOriginDropsDefaultsAndDeniedOriginDoesNotSend`
- `loopbackCredentialsFailBeforeTransport`

## FixtureProcessTests.swift

[Source](../../Tests/NetworkKitTests/FixtureProcessTests.swift) — 2 macOS-only declarations; no placeholder executions on other platforms.

- `missingReadinessFailsAndStopsTheChild`
- `childIgnoringTerminationIsForceStoppedWithinTheBound`

## HTTPPipelineTests.swift

[Source](../../Tests/NetworkKitTests/HTTPPipelineTests.swift) — 12 declarations.

- `jsonThroughSession`
- `dataTextAndEmptyThroughSession`
- `statusPrecedesDecodingAndExplicitPolicyWorks`
- `invalidJSONAndContentTypeRemainStructured`
- `transportErrorsAreSanitizedAndNeverRetried`
- `systemTimeoutAndUnexplainedCancellationAreDistinct`
- `securityRejectsBeforeTransport`
- `preCancelledCallsDoNotSend`
- `constructorsRejectInsecureBaseAndIncompatibleSession`
- `sessionFailureUsesSharedNormalization`
- `nonHTTPResponseIsRejectedAfterTransport`
- `preparedHeadersAndTimeoutReachTransport`

## NetworkKitTests.swift

[Source](../../Tests/NetworkKitTests/NetworkKitTests.swift) — 21 declarations.

- `standardMethodsAndCaseSensitivity`
- `tokenAlphabetIsASCIIOnly`
- `invalidMethodsFailWithoutEchoingInput`
- `customMethodsDoNotAppearInDescriptions`
- `caseInsensitiveLookupPreservesOpaqueValues`
- `equalDuplicatesCollapseButConflictsFail`
- `invalidNamesAreRejected`
- `controlsAreRejectedExceptHorizontalTab`
- `opaqueValuesAreNotUnicodeNormalized`
- `lookupRejectsUnicodeAliasesAndMalformedNames`
- `snapshotsDoNotChangeWithInputOrExportedDictionary`
- `descriptionsDoNotExposeNamesOrValues`
- `everyValidStatusHasTheExpectedDefaultClassification`
- `invalidStatusesAreRejected`
- `valuesAndMetadataRemainAvailableWithoutImplicitDecoding`
- `payloadSnapshotsAndDescriptionsDoNotLeak`
- `publicValuesCanCrossTaskBoundaries`
- `transportIdentityPreservesCodeWithoutUnderlyingUserInfo`
- `httpErrorsRetainExplicitMetadataButDescriptionsAreSanitized`
- `categoriesRemainDistinctAndAllDescriptionsAreSafe`
- `cancellationRemainsASeparateSwiftError`

## NetworkSecurityTests.swift

[Source](../../Tests/NetworkKitTests/NetworkSecurityTests.swift) — 21 declarations.

- `originNormalizationAndSafeDescriptions`
- `HTTPIsDeniedByDefault`
- `explicitLoopbackPermission`
- `loopbackLookalikesAndNoncanonicalAddressesFail`
- `HTTPDoesNotAcceptCredentialOrCustomHeaders`
- `HTTPMetadataAndTypedRawParity`
- `explicitExtraRawOriginDropsAllClientDefaultHeaders`
- `approvedRedirectsAndEffectivePorts`
- `unsafeRedirectsAreRefusedEvenWithExtraOriginPermission`
- `mutatingAndNonSelectedMethodsAreNeverReplayed`
- `HEADPreservesMethodAndRejectsBodyOrChangedMethod`
- `sixthHopAndLoopsBecomeStructuredErrors`
- `trustUsesSystemAndOtherChallengesNeverSupplyCredentials`
- `challengeCallbacksDiscardEvenProposedCredentials`
- `deniedInitialDestinationsNeverReachDataOperation`
- `redirectCallbackRejectsBeforeExecutorCanFollow`
- `loopFailurePropagatesThroughAdapter`
- `loopbackTransportDisablesAutomaticHandlingAndRejectsAppStores`
- `additionalPermissionDoesNotAuthorizeInsecureRemoteOrigin`
- `additionalRawOriginCannotInheritAnAppManagedCookieStore`
- `credentialStoresAndSessionGlobalHeadersAreRejected`

## OperationBudgetTests.swift

[Source](../../Tests/NetworkKitTests/OperationBudgetTests.swift) — 16 declarations.

- `defaultBudgetExpiresAndJoinsBothChildren`
- `callOverridesClientLimits`
- `clientLimitsOverrideLibraryDefaults`
- `preCancelledCallerDoesNotStartTransport`
- `cancellationDuringIOStopsAndJoinsWork`
- `cancellationIsScopedToOneCall`
- `encodingTimeCannotSendAfterExpiration`
- `optionsAndSchedulingTimeBelongToBudget`
- `decodingTimeCannotProduceLateSuccess`
- `futureSuspendingHookIsInsideOperationBudget`
- `systemTimeoutIsDistinctFromTotalTimeout`
- `firstRecordedInterruptionSurvivesCleanupRace`
- `selectedCompletionSurvivesCancellationWhileWatchdogJoins`
- `extremePositiveBudgetsDoNotOverflowOrLeaveSleepers`
- `longBudgetContinuesAcrossBoundedSleeps`
- `borrowedSessionStopsOnlyThisOperation`

## PublicResponseAPITests.swift

[Source](../../Tests/NetworkKitTests/PublicResponseAPITests.swift) — 8 declarations.

- `externalConsumerSelectsBorrowedStorageProfile`
- `externalConsumerReceivesOnlySanitizedDiagnostics`
- `externalConsumerCanConfigureAuthenticationProvider`
- `externalConsumerCanShutdownThroughClientBoundary`
- `systemTimeoutRetainsOnlySafeTransportIdentity`
- `externalConsumerCanInjectAndExecuteClientBoundary`
- `externalConsumerCanBorrowCompatibleSession`
- `externalConsumerCanSelectTypedAndRawStrategies`

## RedirectIntegrationTests.swift

[Source](../../Tests/NetworkKitTests/RedirectIntegrationTests.swift) — 3 declarations.

- `deniedRedirectDestinationIsNotContacted`
- `terminalRedirectFailureCancelsOnlyItsUnderlyingTask`
- `sameOriginRedirectsHaveABoundedLifetime`

## RequestEncodingTests.swift

[Source](../../Tests/NetworkKitTests/RequestEncodingTests.swift) — 20 declarations.

- `defaultEndpointHasNoBodyOrInventedContentType`
- `dataAndEmptyDataAreExplicitBodies`
- `textUsesExactUTF8`
- `jsonDefaultsAndNull`
- `jsonOptionsUseNativeStrategies`
- `jsonFloatAndOutputFormatting`
- `explicitHeadersAndContentTypeWinWithoutChangingBytes`
- `methodsArePreserved`
- `normalizedCustomMethodIsNotSilentlyChanged`
- `bodylessMethodsRejectBodies`
- `encodingFailureIsSanitizedAndDoesNotPoisonNextCall`
- `encodingCancellationIsNotOrdinaryFailure`
- `concurrentEncodersHaveIndependentStrategiesAndPayloads`
- `descriptionsExcludePayloadAndFormattingValues`
- `rawBodyHeadersAndCallPrecedence`
- `rawExplicitContentTypeAndNoBody`
- `rawStreamsAndMalformedMethodsFailLocally`
- `managedHeadersAreRejected`
- `rawHeadersUseExistingValidation`
- `foundationDiscardedCRLFIsNotReintroduced`

## ResponseDecodingTests.swift

[Source](../../Tests/NetworkKitTests/ResponseDecodingTests.swift) — 19 declarations.

- `jsonAndMetadata`
- `acceptedJSONMediaTypes`
- `missingContentTypeIsAllowed`
- `rejectsIncorrectOrAmbiguousJSONMediaType`
- `statusWinsOverCodingAndContentType`
- `malformedOrEmptyJSONFails`
- `explicitEmpty204AndHEADSemantics`
- `dataIsUnchangedAndDoesNotImposeContentType`
- `textUsesStrictUTF8`
- `textWithoutContentTypeAndInvalidBytes`
- `unsupportedOrInvalidTextDeclarationFails`
- `rejectsNonHTTPAndInvalidStatus`
- `customDecoderFailuresAreSanitized`
- `appleDecoderOptionsAndDefaultValues`
- `typedAndRawStrategiesShareStatusRules`
- `parallelDecodersDoNotShareStrategyOrPayload`
- `cancellationBeforeAndAfterSynchronousDecoding`
- `defaultsAndBoundaries`
- `rejectsEmptyOrInvalidPolicies`

## SessionTransportTests.swift

[Source](../../Tests/NetworkKitTests/SessionTransportTests.swift) — 14 declarations.

- `strictConfigurationDisablesAutomaticStorage`
- `ownedSessionIsReusedAndSnapshotsItsConfiguration`
- `injectedSessionSurvivesAdapterCleanupAndDeinit`
- `defaultStoredSessionsRequireExplicitAppManagedPolicy`
- `externalDelegateIsRejectedEvenWithAppManagedStorage`
- `strictInjectionRejectsEachIncompatibleSetting`
- `concurrentCallsOnOneSessionRemainIndependent`
- `streamsAreRejectedBeforeTransport`
- `cancellationAtEntryDoesNotStartRequest`
- `externalInvalidationStopsAnActiveBorrowedOperation`
- `invalidResourceLimitsAndOwnedStoresAreRejected`
- `strictRequestCopyPreventsCookieAndCacheOverrides`
- `backgroundConfigurationRejectedWhereAvailable`
- `resourceLimitRemainsSeparateFromRequestedTotalBudget`

## StorageIntegrationTests.swift

[Source](../../Tests/NetworkKitTests/StorageIntegrationTests.swift) — 8 declarations.

- `strictProfileDoesNotRetainOrSendCookies`
- `strictProfileCannotServeAnAutomaticHTTPCacheEntry`
- `ownedStrictProfileNeverSuppliesBasicChallengeCredentials`
- `publicProfilesRejectCredentialsGlobalHeadersDelegatesAndBackgrounds`
- `appManagedActiveStoresCannotRunOverLoopbackHTTP`
- `appManagedCookiesCannotFollowAdditionalRawOriginPermission`
- `additionalRawOriginWithoutCookiesCannotUseAppCachePolicy`
- `appManagedCookieCacheProfileRequiresExplicitPublicSelection`

