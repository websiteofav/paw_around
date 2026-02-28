class AppStrings {
  // App Information
  static const String appName = 'PawAround';
  static const String appTagline =
      'Discover vets, groomers\n& pet friends nearby';
  static const String getStartedButton = 'Get Started';
  static const String welcomeMessage = 'Welcome to PawAround! 🐾';

  // Intro Screen
  static const String introTitle = 'PawAround';
  static const String introDescription =
      'Discover vets, groomers\n& pet friends nearby';

  // Onboarding Screen
  static const String skipButton = 'Skip';
  static const String nextButton = 'Next';

  // Onboarding Page 1 - Tracking (FIRST)
  static const String onboarding1Title = 'Track vaccines & care';
  static const String onboarding1Description =
      'Smart reminders so you never miss what your pet needs';

  // Onboarding Page 2 - Nearby services
  static const String onboarding2Title = 'Find trusted care near you';
  static const String onboarding2Description =
      'Vets, groomers, and pet stores around you';

  // Onboarding Page 3 - Community & safety (LAST)
  static const String onboarding3Title = 'Get help from your community';
  static const String onboarding3Description =
      'Alert nearby pet parents when it matters most';

  // Authentication Screen - Phone Login
  static const String welcomeToPawAround = 'Welcome to Paw Around';
  static const String authSubtitle =
      "Caring for your pet's health, every step of the way";
  static const String phoneNumber = 'Phone Number';
  static const String continueButton = 'Continue';
  static const String orContinueWith = 'or continue with';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithEmail = 'Continue with Email';
  static const String termsText = 'By continuing, you agree to our';
  static const String termsOfService = 'Terms of Service';
  static const String and = 'and';
  static const String privacyPolicyLink = 'Privacy Policy';
  static const String privacyPolicyUrl =
      'https://websiteofav.github.io/pawaround-privacy/';
  static const String termsOfServiceUrl =
      'https://websiteofav.github.io/pawaround-privacy/terms/';

  // OTP Verification Screen
  static const String verifyYourNumber = 'Verify your number';
  static const String otpSentTo = 'We sent a 6-digit code to';
  static const String enterCode = 'Enter code';
  static const String verify = 'Verify';
  static const String didntReceiveCode = "Didn't receive the code?";
  static const String resendOTP = 'Resend';
  /// Use for countdown, e.g. resendOTPInSeconds(45) => "Resend in 45s"
  static String resendOTPInSeconds(int seconds) => 'Resend in ${seconds}s';
  static const String invalidOTP = 'Invalid OTP. Please try again.';
  static const String otpSentSuccessfully = 'OTP sent successfully';

  // Legacy Auth Strings (for email login)
  static const String welcomeBack = 'Welcome Back?';
  static const String loginInstruction =
      'Log in to continue caring for your pet.';
  static const String orSeparator = 'or';
  static const String emailAddress = 'Email Address';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String logIn = 'Log In';
  static const String noAccount = "Don't have an account?";
  static const String signUp = 'Sign Up';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String createAccount = 'Create Your Account';
  static const String signupSubtitle = 'Join the pet parent community today.';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Navigation
  static const String homeTab = 'Home';
  static const String mapTab = 'Map';
  static const String momentsTab = 'Moments';
  static const String communityTab = 'Community';
  static const String profileTab = 'Profile';

  // Tab Content
  static const String homeWelcome = 'Welcome to Home';
  static const String homeDescription = 'Dashboard content will go here';
  static const String mapTitle = 'Services Map';
  static const String mapDescription =
      'Find vets, groomers & pet stores nearby';
  static const String communityTitle = 'Lost & Found';
  static const String communityDescription =
      'Connect with pet parents in your area';
  static const String profileTitle = 'Your Profile';
  static const String profileDescription =
      'Manage your pets and account settings';
  static const String addPet = 'Add Pet';
  static const String upcomingVaccinesAndAppointments =
      'Upcoming Vaccines & Appointments';
  static const String viewDetails = 'View Details';
  static const String lostAndFoundNearby = 'Lost & Found Nearby';
  static const String featuredServices = 'Featured Services';
  static const String petAddedSuccessfully = 'Pet added successfully!';
  static const String petName = 'Pet Name';
  static const String breed = 'Breed';
  static const String pleaseEnterBreed = 'Please enter breed';
  static const String pleaseEnterPetName = 'Please enter pet name';
  static const String pleaseSelectDateOfBirth = 'Please select date of birth';

  // Pet Management
  static const String species = 'Species';
  static const String petType = 'Pet type';
  static const String gender = 'Gender';
  static const String genderOptional = 'Gender (optional)';
  static const String dateOfBirth = 'Date of Birth';
  static const String birthdateOrAge = 'Birth Date or Age';
  static const String weight = 'Weight (kg)';
  static const String notes = 'Notes';
  static const String addPhoto = 'Add Photo';
  static const String selectSpecies = 'Select Species';
  static const String selectGender = 'Select Gender';
  static const String selectDate = 'Select date';
  static const String dog = 'Dog';
  static const String cat = 'Cat';
  static const String bird = 'Bird';
  static const String fish = 'Fish';
  static const String other = 'Other';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String savePet = 'Save Pet';
  static const String saveAndContinue = 'Save & continue';
  static const String cancel = 'Cancel';
  static const String addVaccine = 'Add Vaccine';
  static const String editVaccine = 'Edit Vaccine';
  static const String addVaccineFor = 'Add Vaccine for';
  static const String petTypeOtherHelper =
      'Some care reminders are currently available only for dogs and cats.';
  static const String lessThan1Year = 'Less than 1 year';
  static const String oneToThreeYears = '1-3 years';
  static const String threeToSevenYears = '3-7 years';
  static const String moreThan7Years = '7+ years';
  static const String pleaseEnterBirthdateOrAge =
      'Please enter either birthdate or age';
  static const String addYourPet = 'Add your pet';

  // Vaccine Management
  static const String vaccineName = 'Vaccine Name';
  static const String dateGiven = 'Date Given';
  static const String nextDueDate = 'Next Due Date';
  static const String setReminder = 'Set Reminder';
  static const String saveVaccine = 'Save Vaccine';
  static const String pleaseEnterVaccineName = 'Please enter vaccine name';
  static const String pleaseSelectDateGiven = 'Please select date given';
  static const String pleaseSelectNextDueDate = 'Please select next due date';
  static const String vaccineAddedSuccessfully = 'Vaccine added successfully!';
  static const String vaccinations = 'Vaccinations';
  static const String noVaccinesAddedYet = 'No vaccines added yet';
  static const String selectVaccineFromDropdown =
      'Select a vaccine from the dropdown to add your first vaccine';
  static const String given = 'Given';
  static const String next = 'Next';
  static const String removeVaccine = 'Remove vaccine';
  static const String reminderNotification = 'Reminder Notification';
  static const String getNotifiedBeforeNextDose =
      'Get notified before the next dose is due';

  // Vaccines Setup Screen
  static const String vaccines = 'Vaccines';
  static const String notAdded = 'Not added';
  static const String addDate = 'Add date';
  static const String edit = 'Edit';
  static const String lastGivenOn = 'Last given on';
  static const String lastGivenDate = 'Last given date';
  static const String vaccinesForDogsCatsOnly =
      'Vaccines are currently available only for dogs and cats.';

  // Vaccine Selection Categories
  static const String requiredCore = 'Required / Core';
  static const String recommendedVaccines = 'Recommended';
  static const String requiredByLaw = 'Required by law';
  static const String requiredBadge = '⚠ Required';
  static const String otherVaccine = 'Other';
  static const String enterCustomVaccine = 'Enter a custom vaccine';
  static const String customVaccineName = 'Custom vaccine name';
  static const String vaccineSaved = 'Vaccine saved successfully!';
  static const String autoCalculatedHelperText =
      'Auto-calculated based on vaccine frequency. Disable reminder if it\'s a one-time vaccine.';
  static const String nextDueDateAfterDateGiven =
      'Next due date must be after date given';
  static const String petRequiredForVaccine = 'Pet is required to save vaccine';

  // Map Screen
  static const String petServices = 'Pet Services';
  static const String gettingYourLocation = 'Getting your location...';
  static const String loadingNearbyServices = 'Finding nearby services...';
  static const String somethingWentWrong = 'Something went wrong';
  static const String retry = 'Retry';
  static const String petServicesFoundNearby = 'pet services found nearby';
  static const String noServicesNearby = 'No services nearby';
  static const String tryDifferentLocation =
      'Try searching in a different location';
  static const String open = 'Open';
  static const String closed = 'Closed';
  static const String locationPermissionRequired =
      'Location Permission Required';
  static const String locationPermissionDeniedMessage =
      'Location permission has been permanently denied. Please enable it in app settings to use the map feature.';
  static const String openAppSettings = 'Open App Settings';
  static const String locationServicesDisabled = 'Location Services Disabled';
  static const String locationServicesDisabledMessage =
      'Please enable location services in your device settings to use the map feature.';
  static const String openLocationSettings = 'Open Location Settings';

  // Community Screen
  static const String lost = 'Lost';
  static const String found = 'Found';
  static const String reportLostPet = 'Report Lost Pet';
  static const String reportFoundPet = 'Report Found Pet';
  static const String createLostFoundPost = 'Create Lost/Found Post';
  static const String postLostPet = 'Post Lost Pet';
  static const String postFoundPet = 'Post Found Pet';
  static const String petDescription = 'Pet Description';
  static const String color = 'Color';
  static const String location = 'Location';
  static const String searchForLocation = 'Search for location';
  static const String contactPhone = 'Contact Phone';
  static const String selectPostType = 'Select Post Type';
  static const String describeThePet =
      'Describe the pet (size, markings, etc.)';
  static const String enterContactPhone = 'Enter contact phone number';
  static const String postCreatedSuccessfully = 'Post created successfully!';
  static const String noPostsYet = 'No posts near you';
  static const String helpReunitePets =
      'Help reunite lost pets with their families';
  static const String alertNearbyParents =
      'Alert pet parents in your neighborhood';
  static const String locationRequiredForNearbyPosts =
      'Location permission required to see nearby posts';
  static const String enableLocationToSeeNearbyPosts =
      'Enable location to see lost and found posts near you';
  static const String noPostsInYourArea = 'No posts found in your area';
  static const String markAsResolved = 'Mark as Resolved';
  static const String reopenPost = 'Reopen Post';
  static const String postReopenedSuccessfully = 'Post reopened successfully';
  static const String getDirections = 'Get Directions';
  static const String callOwner = 'Call Owner';
  static const String kmAway = 'km away';
  static const String ago = 'ago';
  static const String useCurrentLocation = 'Use Current Location';
  static const String lastSeenAt = 'Last seen at';
  static const String foundAt = 'Found at';
  static const String postedBy = 'Posted by';
  static const String posted = 'Posted';
  static const String deletePost = 'Delete Post';
  static const String deletePostConfirmation =
      'Are you sure you want to delete this post? This action cannot be undone.';
  static const String postDeletedSuccessfully = 'Post deleted successfully';
  static const String required = 'Required';
  static const String pleaseSetLocation = 'Please set a location';

  // Home Screen - New Design
  static const String findNearbyVets = 'Find nearby vets';
  static const String vetsWithinDistance = 'vets within 2 km';
  static const String importantForHealth = "Important for your pet's health";
  static const String groomingDueThisWeek = 'Grooming due this week';
  static const String timeForFreshTrim = 'Time for a fresh trim';
  static const String tickFleaPrevention = 'Tick & Flea Prevention';
  static const String reminderToProtect = 'Reminder to protect your pet';
  static const String lostPetsNearYou = 'Lost pets near you';
  static const String seeAll = 'See all';
  static const String allSetForNow = 'All set for now';
  static const String wellNotifyWhenDue =
      "We'll notify you when something is due.";
  static const String months = 'months';
  static const String daysUntilDue = 'days';
  static const String vaccineDueIn = 'vaccine due in';

  // Home Screen - Empty States
  static const String welcomeToPawAroundHome = 'Start by adding your pet';
  static const String addPetToGetStarted =
      'Track vaccines, grooming, and care reminders in one place.';
  static const String addYourFirstPet = 'Add my pet';
  static const String completeHealthDetails = "Complete %s's health details";
  static const String addVaccineDetails = 'Add vaccine details';

  // Welcome Card Benefits
  static const String neverMissVaccines = 'Never miss vaccines & appointments';
  static const String findVetsNearby = 'Find vets & groomers nearby';
  static const String trackHealthWellness = 'Track health & wellness';

  // Add Pet Flow - Step 2
  static const String step1Of2 = 'Step 1 of 2';
  static const String step2Of2Optional = 'Step 2 of 2 (Optional)';
  static const String addMoreDetailsOptional = 'Add more details (optional)';
  static const String addMoreDetailsSubtitle =
      'You can skip this and add it later anytime.';
  static const String saveDetails = 'Save details';
  static const String skipForNow = 'Skip for now';
  static const String addBreedForBetterCare =
      'Add breed to get better care suggestions';

  // Care Settings Screens
  static const String grooming = 'Grooming';
  static const String frequency = 'Frequency';
  static const String noReminder = 'No reminder';
  static const String everyWeek = 'Every week';
  static const String everyMonth = 'Every month';
  static const String every3Months = 'Every 3 months';
  static const String lastGrooming = 'Last grooming';
  static const String lastTreatment = 'Last treatment';
  static const String save = 'Save';
  static const String today = 'Today';
  static const String settingsSaved = 'Settings saved successfully';
  static const String addGroomingDetails = 'Add grooming schedule';
  static const String addTickFleaDetails = 'Add treatment schedule';

  // Setup Reminder Card Subtitles
  static const String vaccineSubtitle = 'Protect against common diseases';
  static const String groomingSubtitle = 'Keep coat healthy & tangle-free';
  static const String tickFleaSubtitle = 'Prevent parasites & infections';
  static const String itemsRemaining = 'items remaining';
  static const String itemRemaining = 'item remaining';
  static const String quickSetup = '~1 min';
  static const String remindMeLater = 'Remind me later';

  // Home Screen - Care Setup
  static const String setUpCareForYourPet = 'Set up care for your pet';
  static const String recommended = 'Recommended';
  static const String setRemindersForVaccines =
      'Set reminders for upcoming vaccines';
  static const String trackDewormingPreventive =
      'Track deworming & preventive care';
  static const String scheduleGroomingReminders =
      'Schedule regular grooming reminders';
  static const String noCareTasksYet =
      'No care tasks yet — add one to get started';

  // Action Card Detail Screen
  static const String vaccine = 'Vaccine';
  static const String whyThisMatters = 'Why this matters';
  static const String whatYouCanDoNow = 'What you can do now';
  static const String learnMore = 'Learn more';
  static const String markAsDone = 'Mark as done';
  static const String snooze = 'Snooze';
  static const String dueSoon = 'Due soon';
  static const String overdue = 'Overdue';
  static const String forPet = 'For';
  static const String findGroomers = 'Find groomers';
  static const String viewTreatmentOptions = 'View treatment options';
  static const String vetsAvailableNearby = '3 vets available within 2 km';
  static const String groomersAvailableNearby =
      '3 groomers available within 2 km';
  static const String treatmentOptionsAvailable = 'Treatment options available';
  static const String noNearbyServices =
      'No nearby services found. Try expanding your search.';
  static const String vaccineExplanation =
      'Rabies vaccination is essential to protect your pet and is required by law in many places.';
  static const String groomingExplanation =
      'Regular grooming keeps your pet healthy, comfortable, and helps prevent skin issues and matting.';
  static const String tickFleaExplanation =
      'Tick and flea prevention protects your pet from parasites that can cause serious health problems.';

  // Snooze Options
  static const String snoozeFor3Days = 'Snooze for 3 days';
  static const String snoozeFor7Days = 'Snooze for 7 days';
  static const String snoozeAction = 'Snooze this reminder';
  static const String reminderSnoozed = 'Reminder is snoozed';
  static const String snoozed = 'Snoozed';
  static const String reminderUnsnoozed = 'Reminder is now active';
  static const String unsnooze = 'Unsnooze';

  // Mark as Done
  static const String confirmMarkDone = 'Mark as completed?';
  static const String markDoneDescription =
      'This will update the last completed date and calculate the next due date.';
  static const String confirm = 'Confirm';
  static const String markedAsDone = 'Marked as done';
  static const String doneToday = 'Done today';
  static const String doneEarlier = 'Done earlier';
  static const String changeDate = 'Change date';
  static const String completionDate = 'Completion date';

  // Care History Card
  static const String careHistory = 'Care History';
  static const String lastCompleted = 'Last completed';
  static const String nextDue = 'Next due';

  // Action Timeline
  static const String actionTimeline = 'Action Timeline';
  static const String skipped = 'Skipped';
  static const String done = 'Done';
  static const String noTimelineEntries = 'No actions recorded yet';

  // Profile Screen
  static const String myPets = 'My Pets';
  static const String myPosts = 'My Posts';
  static const String savedPlaces = 'Saved Places';
  static const String notificationSettings = 'Notification Settings';
  static const String editProfile = 'Edit Profile';
  static const String displayName = 'Display Name';
  static const String displayNameHint = 'Enter your name';
  static const String emailHint = 'Enter your email';
  static const String emailChangeNote =
      'A verification email will be sent to confirm this change';
  static const String emailVerificationSent =
      'Verification email sent! Please check your inbox.';
  static const String updateProfile = 'Update Profile';
  static const String profileUpdatedSuccessfully =
      'Profile updated successfully!';
  static const String upgradeToPremium = 'Upgrade to Premium';
  static const String helpAndSupport = 'Help & support';
  static const String privacyPolicy = 'Privacy Policy';
  static const String notifications = 'Notifications';
  static const String privacyAndSecurity = 'Privacy & Security';
  static const String logout = 'Log out';
  static const String appVersion = 'Version';
  static const String pressBackAgainToExit = 'Press back again to exit';
  static const String pets = 'pets';
  static const String posts = 'Posts';
  static const String activity = 'Activity';
  static const String settings = 'Settings';
  static const String account = 'Account';
  static const String addAnotherPet = 'Add another pet';
  static const String switchPet = 'Switch Pet';
  static const String unknownBreed = 'Unknown breed';
  static const String currentlySelected = 'currently selected';
  static const String accountSettings = 'Account settings';
  static const String logOutConfirmTitle = 'Log out?';
  static const String logOutConfirmMessage =
      'You will need to sign in again to access Paw Around.';
  static const String daysOld = 'days old';
  static const String monthsOld = 'months old';
  static const String yearsOld = 'years old';
  static const String noPetsAddedYet = 'No pets added yet';
  static const String addFirstPetToStart = 'Add your first pet to get started';

  // Pet Overview Screen
  static const String editPetDetails = 'Edit pet details';
  static const String someCareDue = 'Some care due';
  static const String allCaughtUp = 'All caught up';
  static const String comingUp = 'coming up';
  static const String upcomingSoon = 'Upcoming soon';
  static const String nextDoseSoon = 'Next dose soon';
  static const String notSet = 'Not set';
  static const String valueNotSet = '--';
  static const String noVaccinesAdded = 'No vaccines added';
  static const String petNameHint = "Pet's name";
  static const String delete = 'Delete';
  static const String deletePet = 'Delete Pet';
  static const String deletePetConfirmTitle = 'Delete Pet?';
  static const String deletePetConfirmMessage =
      'Are you sure you want to delete this pet? This action cannot be undone.';
  static const String petDeletedSuccessfully = 'Pet deleted successfully';
  static const String selectVaccine = 'Select vaccine';
  static const String optionalNotesHint = 'Optional notes...';
  static const String deleteVaccine = 'Delete Vaccine';
  static const String deleteVaccineConfirmTitle = 'Delete Vaccine?';
  static const String deleteVaccineConfirmMessage =
      'Are you sure you want to delete this vaccine record?';
  static const String vaccineDeletedSuccessfully =
      'Vaccine deleted successfully';
  static const String allGood = 'All good';
  static const String thisWeek = 'This Week';
  static const String groomingSession = 'Grooming Session';
  static const String scheduleAppointment = 'Schedule appointment';
  static const String protectionActive = 'Protection is active and working';
  static const String daysLeft = 'days left';
  static const String careSummary = 'Care Summary';
  static const String activeTasks = 'Active Tasks';
  static const String urgent = 'Urgent';
  static const String scheduled = 'Scheduled';
  static const String enableReminders = 'Enable Reminders';
  static const String enable = 'Enable';
  static const String notNow = 'Not Now';
  // Delete Account
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountTitle = 'Delete Account?';
  static const String deleteAccountWarning =
      'This will permanently delete your account and all associated data including:';
  static const String deleteAccountBullet1 = 'Your profile information';
  static const String deleteAccountBullet2 = 'All your pets and their records';
  static const String deleteAccountBullet3 =
      'Your posts and community activity';
  static const String deleteAccountFinal = 'This action cannot be undone.';
  static const String deleteAccountConfirm = 'Delete My Account';
  static const String deletingAccount = 'Deleting account...';
  static const String accountDeletedSuccessfully =
      'Account deleted successfully';
  static const String reAuthRequired =
      'Please sign in again to confirm deletion';

  // Pet Overview Screen
  static const String tapToUnsnooze = 'Tap to unsnooze';
  static const String dueToday = 'Due today';
  static const String overdueByDays = 'Overdue by %s days';
  static const String dueInDays = 'Due in %s days';
  static const String yourPet = 'Your Pet';

  // Pet ID & QR
  static const String markPetAsLost = 'Mark pet as lost';
  static const String scanMeToHelpGetHome = 'Scan me to help me get home 🐾';
  static const String qrNotAvailableForPet =
      'QR code not available for this pet';
  static const String petMarkedAsLost = 'Pet marked as lost';
  static const String petNoLongerMarkedAsLost = 'Pet no longer marked as lost';
  static const String viewPetQr = 'Pet ID & QR Code';
  static const String markLostLastSeenTitle = 'When & where last seen';
  static const String markLostLastSeenDescription =
      'Help finders by adding when and where you last saw your pet.';
  static const String lastSeenDateAndTime = 'Date & time';
  static const String lastSeenLocationLabel = 'Last seen location';
  static const String lastSeenLocationHint =
      'e.g. Central Park, near the fountain';

  // Private constructor to prevent instantiation

  // Edit Profile Screen
  static const String phoneNumberCannotBeChangedHere =
      'Phone number cannot be changed here';
  static const String mobileNumber = 'Mobile Number';

  // My Posts Screen
  static const String noMyPostsYet = "You haven't posted yet";
  static const String noMyPostsSubtitle =
      'Your lost & found posts will appear here';
  static const String resolved = 'Resolved';

  // Help & Support Screen
  static const String frequentlyAskedQuestions = 'Frequently Asked Questions';
  static const String contactUs = 'Contact Us';
  static const String stillNeedHelp = 'Still need help?';
  static const String sendUsEmail =
      'Send us an email and we\'ll get back to you as soon as possible.';
  static const String emailSupport = 'Email Support';
  static const String supportEmail = 'avinashlabs.dev@gmail.com';

  // FAQ Questions
  static const String faqAddPetQuestion = 'How do I add a pet?';
  static const String faqAddPetAnswer =
      'Tap the "Add Pet" button on the home screen or go to Profile > My Pets > Add Pet. Fill in your pet\'s details like name, breed, and birthdate.';

  static const String faqVaccineRemindersQuestion =
      'How do vaccine reminders work?';
  static const String faqVaccineRemindersAnswer =
      'Once you add vaccine records for your pet, we\'ll automatically calculate the next due date and send you reminders before it\'s due. You can manage reminders in your pet\'s profile.';

  static const String faqLostFoundQuestion =
      'How do I report a lost or found pet?';
  static const String faqLostFoundAnswer =
      'Go to the Community tab and tap the "+" button. Select whether you\'re reporting a lost or found pet, add details and a photo, and set the location where the pet was last seen or found.';

  static const String faqFindVetsQuestion = 'How do I find vets near me?';
  static const String faqFindVetsAnswer =
      'Go to the Map tab to see veterinary clinics, groomers, and pet stores near your location. Tap on any marker to see details, ratings, and get directions.';

  static const String faqDeleteAccountQuestion = 'How do I delete my account?';
  static const String faqDeleteAccountAnswer =
      'Go to Profile > Delete Account. This will permanently delete your account and all associated data including pets, posts, and records. This action cannot be undone.';

  static const String faqContactSupportQuestion = 'How do I contact support?';
  static const String faqContactSupportAnswer =
      'You can email us at support@pawaround.app. We typically respond within 24-48 hours.';
  static const String oneTimeVaccine = 'One-time vaccine';

  static const String mostPetsNeedMonthlyPrevention =
      'Most pets need monthly prevention';
  static const String chooseHowOftenYouGroomYourPet =
      'Choose how often you groom your pet';

  static const String lostPetsAreOftenFoundWithinTheFirst2448Hours =
      'Lost pets are often found within the first 24–48 hours';
  static const String shareDetailsToHelpIdentifyPet =
      'The more details you share, the easier it is to identify your pet.';
  static const String lastSeenLocation = 'Last seen location';
  static const String yourContactWillOnlyBeVisibleToPeopleViewingThisPost =
      'Your contact will only be visible to people viewing this post.';
  static const String anonymous = 'Anonymous';
  static const String details = 'Details';
  static const String yourPost = 'Your post';
  static const String pawCircle = 'Paw Circle';
  static const String explore = 'Explore';

  // Share
  static const String sharePost = 'Share Post';
  static const String lostPetAlert = 'Lost Pet Alert!';
  static const String foundPetAlert = 'Found Pet Alert!';

  static const String goToHome = 'Go to Home';
  static const String removePhoto = 'Remove photo';
  static const String community = 'community';
  static const String petParent = 'Pet Parent';

  // Moments
  static const String createMoment = 'Create Moment';
  static const String addCaption = 'Add Caption';
  static const String selectPet = 'Select Pet';
  static const String momentCaptionHint = 'What\'s happening with your pet?';
  static const String noMomentsYet = 'No moments yet';
  static const String noMomentsDescription =
      'Share your pet\'s special moments with the community';
  static const String likeMoment = 'Like';
  static const String unlikeMoment = 'Unlike';
  static const String addComment = 'Add Comment';
  static const String commentHint = 'Write a comment...';
  static const String postMoment = 'Post Moment';
  static const String momentPosted = 'Moment posted successfully';
  static const String momentDeleted = 'Moment deleted';
  static const String deleteMoment = 'Delete Moment';
  static const String deleteMomentConfirmation =
      'Are you sure you want to delete this moment? This action cannot be undone.';
  static const String myMoments = 'My Moments';
  static const String noMyMomentsYet = "You haven't shared any moments yet";
  static const String noMyMomentsSubtitle =
      'Create a moment to share with the community';
  static const String selectImageForMoment = 'Select Image';
  static const String takePhoto = 'Take a photo';
  static const String chooseFromGallery = 'Choose from gallery';
  static const String postingMoment = 'Posting moment...';
  static const String failedToPostMoment =
      'Failed to post moment. Please try again.';
  static const String failedToUploadImage =
      'Failed to upload image. Please try again.';
  static const String pleaseSelectImage = 'Please select an image';
  static const String pleaseEnterCaption = 'Please enter a caption';
  static const String pleaseSelectPet = 'Please select a pet';
  static const String comments = 'Comments';
  static const String noCommentsYet = 'No comments yet';
  static const String beFirstToComment = 'Be the first to comment!';

  // Community Action Bottom Sheet
  static const String whatWouldYouLikeToShare = 'What would you like to share?';
  static const String shareMoment = 'Share a Moment';
  static const String reportLostPetDescription =
      'Help reunite a lost pet with their family';
  static const String reportFoundPetDescription = 'Report a pet you found';
  static const String shareMomentDescription =
      'Share a special moment with your pet';
  static const String lostAndFoundTab = 'Lost & Found';

  // Web Landing Page - Navigation
  static const String landingNavHome = 'Home';
  static const String landingNavAbout = 'About';
  static const String landingNavFaq = 'FAQ';
  static const String landingNavContact = 'Contact';

  // Web Landing Page - Hero Section
  static const String landingHeroTitle =
      'All Your Pet\'s Care, Safety & Community in One App';
  static const String landingHeroSubtitle =
      'Keeping your pet healthy and safe has never been easier.';
  static const String landingDownloadOnAndroid = 'Download on Android';
  static const String landingIosComingSoon = 'iOS Coming Soon';

  // Web Landing Page - Feature Cards
  static const String landingFeaturePetCareRemindersTitle =
      'Pet Care Reminders';
  static const String landingFeaturePetCareRemindersBody =
      'Never miss a vet visit or grooming.';
  static const String landingFeatureLostFoundTitle = 'Lost & Found QR Tags';
  static const String landingFeatureLostFoundBody =
      'Find your pet quickly if they go missing.';
  static const String landingFeatureNearbyVetsTitle = 'Nearby Vets & Groomers';
  static const String landingFeatureNearbyVetsBody =
      'Book local services in seconds.';

  // Web Landing Page - Feature Section
  static const String landingFeatureSectionTitle =
      'Why Pet Parents Love Paw Around';
  static const String landingFeatureSectionSubtitle =
      'Everything your pet needs in one app';

  // Web Landing Page - QR Safety Section
  static const String landingQrEyebrow = 'SAFETY FIRST';
  static const String landingQrHeading = 'Lost Pet? Scan the QR Tag!';
  static const String landingQrBody =
      'If your pet is lost, anyone can scan their tag to contact you instantly.';
  static const String landingQrCtaPrimary = "Protect Your Pet Now";
  static const String landingQrCtaSecondary = 'Learn how it works';
  static const String landingQrTrustBadge = '10,000+ pets protected';
  static const String landingStaySafeCta = 'Stay Safe';

  // Web Landing Page - Download Section
  static const String landingDownloadHeading = 'Get Paw Around Today!';
  static const String landingDownloadSubheading =
      'Join 10,000+ pet parents keeping their furry friends safe';
  static const String landingDownloadOrScan = 'Or scan to download';
  static const String landingDownloadTrustFree = 'Free Forever';
  static const String landingDownloadTrustSecure = 'Secure & Trusted';
  static const String landingDownloadTrustPrivacy = 'Privacy First';
  static const String landingDownloadSocialDownloads = '10,000+ downloads';
  static const String landingDownloadRating = '4.8';
  static const String landingDownloadFeatureReminders = 'Pet care reminders';
  static const String landingDownloadFeatureQr = 'QR safety tags';
  static const String landingDownloadFeatureVets = 'Find nearby vets';

  // Web Landing Page - Footer
  static const String landingFooterAbout = 'About';
  static const String landingFooterPrivacyPolicy = 'Privacy Policy';
  static const String landingFooterTermsOfService = 'Terms of Service';
  static const String landingFooterCopyright =
      '© 2026 Paw Around. All rights reserved.';
  static const String landingFooterFacebook = 'Facebook';
  static const String landingFooterInstagram = 'Instagram';
  static const String landingFooterTwitter = 'Twitter';
  static const String landingFooterTagline = "Your pet's best friend";

  /// One-liner for meta, manifest, and footer. QR first.
  static const String appShortDescription =
      'Paw Around – QR pet ID, smart pet care reminders, nearby vets, lost & found.';
  static const String landingFooterCompanyDescription =
      'Paw Around – QR pet ID, smart pet care reminders, nearby vets, lost & found.';
  static const String landingFooterProduct = 'Product';
  static const String landingFooterFeatures = 'Features';
  static const String landingFooterHowItWorks = 'How it Works';
  static const String landingFooterPricing = 'Pricing';
  static const String landingFooterFaq = 'FAQ';
  static const String landingFooterCompany = 'Company';
  static const String landingFooterCareers = 'Careers';
  static const String landingFooterContact = 'Contact';
  static const String landingFooterBlog = 'Blog';
  static const String landingFooterSupport = 'Support';
  static const String landingFooterHelpCenter = 'Help Center';
  static const String landingFooterDownload = 'Download';
  static const String landingFooterStayUpdated = 'Stay Updated';
  static const String landingFooterNewsletterHint = 'Enter your email';
  static const String landingFooterSubscribe = 'Subscribe';
  static const String landingFooterNewsletterSuccess =
      'Thanks for subscribing! We\'ll send pet care tips to your inbox.';
  static const String landingFooterNewsletterInvalid =
      'Please enter a valid email.';
  static const String landingFooterSupportEmail = 'support@pawaround.com';
  static const String landingFooterContactUs = 'Contact Us';

  // Web Landing Page - Hero CTAs
  static const String landingPlayStoreOpenError =
      'Unable to open Google Play Store right now. Please try again later.';
  static const String landingIosComingSoonMessage =
      'Paw Around is coming soon to iOS. Stay tuned!';

  // Public Pet Profile (web /p/:petId)
  static const String publicProfileAppTitle = 'Paw Around';
  static const String publicPetTopBarTagline = 'Pet Safety & Care';
  static const String publicPetTopBarDownloadApp = 'Download App';
  static const String publicPetTopBarTrustBadge = '10,000+ users';
  static const String publicPetStatusMissing = 'Missing!';
  static const String publicPetStatusSafeAtHome = 'Safe at Home';
  static const String messageOwner = 'Message Owner';
  static const String shareLocation = 'Share Location';
  static const String basicInfo = 'Basic Info';
  static const String emergencyInfo = 'Emergency Info';
  static const String notesOrSpecialInstructions = 'Notes';
  static const String owner = 'Owner';
  static const String alternateContact = 'Alternate Contact';
  static const String iFoundThisPet = 'I Found This Pet';
  static const String sendMessageToOwner = 'Send a message to the owner...';
  static const String vaccinationStatus = 'Vaccination Status';
  static const String vaccinationUpToDate = 'Up-to-date';
  static const String primaryOwner = 'Primary Owner';
  static const String copyrightPawAround2026 = '© 2026 Paw Around';
  static const String petNotFound = 'Pet not found';
  static const String contactViaPawAround = 'Contact via Paw Around app';
  static const String youFoundThisPetShareLocation =
      'You found this pet. You can share your location.';

  // Public Pet Hero - CTAs and dialogs
  static const String publicPetHeroIFoundYourPet = 'I Found Your Pet!';
  static const String publicPetHeroShareLocationConfirmTitle =
      'Share Your Location?';
  static const String publicPetHeroShareLocationConfirmContent =
      'Send your current location to the pet owner so they can find you.';
  static const String publicPetHeroShareLocationConfirmButton =
      'Share Location';
  static const String publicPetHeroNoContactAvailable =
      'No contact information available for this pet.';
  static const String publicPetHeroSendSms = 'Send SMS';
  static const String publicPetHeroWhatsApp = 'WhatsApp';
  static const String publicPetHeroMessageChoiceTitle = 'Send Message';
  static const String publicPetHeroSmsBodyFound =
      'Hi, I found your pet! I\'m here: ';
  static const String publicPetHeroWhatsAppTextFound =
      'Hi, I found your pet! I\'m here: ';

  // Public Pet Hero - Urgency
  static const String publicPetHeroMissingRecently = 'Recently missing';
  static const String publicPetHeroMissingHours = 'Missing for %s hours';
  static const String publicPetHeroMissingDays = 'Missing for %s days';
  static const String publicPetHeroUrgentPrefix = 'URGENT: ';
  static const String publicPetHeroLastSeen = 'Last seen %s ago';
  static const String publicPetHeroLastSeenLocation = 'Last seen: %s';

  // Public Pet Hero - Image and errors
  static const String publicPetHeroNoPhotoAvailable = 'No photo available';
  static const String publicPetHeroLocationError =
      'Could not get location. Please check permissions.';
  static const String publicPetHeroLocationShared =
      'Opening message app to share your location.';

  // Public Pet Hero - Optional
  static const String publicPetHeroPetProfile = 'Pet Profile';
  static const String publicPetHeroLookFor = 'Look for: %s';

  // Public Pet Owner Card
  static const String publicPetOwnerTapToCall = 'Tap to call';

  AppStrings._();
}
