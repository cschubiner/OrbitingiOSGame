//
//  Kamcord-C-Interface.h
//  Kamcord
//
//  Created by Dennis Qin on 5/13/13.
//  Copyright (c) 2013 Kevin Wang. All rights reserved.
//

#ifndef Kamcord_Kamcord_C_Interface_h
#define Kamcord_Kamcord_C_Interface_h

namespace KamcordC
{
    void SetDeviceBlacklist(bool disableiPod4G,
                                          bool disableiPod5G,
                                          bool disableiPhone3GS,
                                          bool disableiPhone4,
                                          bool disableiPad1,
                                          bool disableiPad2,
                                          bool disableiPadMini);
    
    bool IsEnabled();
    
    const char * DeviceOrientation();
    
    void SetDeviceOrientation(const char * deviceOrientation);
    
    void CaptureFrame();
    
    //////////////////////////////////////////////////////////////////
    /// Share settings
    ///
    
    void SetDefaultTitle(const char * title);
    
    void SetYouTubeSettings(const char * description,
                                          const char * tags);
    
    void SetFacebookAppID(const char * facebookAppID);
    
    void SetFacebookDescription(const char * description);

    void SetDefaultTweet(const char * tweet);
    
    void SetTwitterDescription(const char * twitterDescription);

    void SetDefaultEmailSubject(const char * subject);

    void SetDefaultEmailBody(const char * body);
    
    void SetLevelAndScore(const char * level,
                                        double score);
    
    // Start of deprecated methods. Remove in August 2013.
    void SetFacebookSettings(const char * title,
                                           const char * caption,
                                           const char * description);
    // End of deprecated methods.
    
    //////////////////////////////////////////////////////////////////
    /// Video recording
    ///
    
    void PrepareNextVideo();
    
	bool StartRecording();
    
    bool StopRecording();
    
    bool Pause();
    
    bool Resume();
    
    bool IsRecording();
    
    //////////////////////////////////////////////////////////////////
    /// Kamcord UI
    ///
    
    void ShowView();
    
    void ShowWatchView();
    
    void SetShowVideoControlsOnReplay(bool showControls);
    
    bool ShowVideoControlsOnReplay();
    
    //////////////////////////////////////////////////////////////////
    /// Sundry Methods
    ///
    
    void SetVideoFPS(int videoFPS);
    
    int VideoFPS();
    
    void SetMaximumVideoLength(unsigned int seconds);
    
    unsigned int MaximumVideoLength();
    
    //////////////////////////////////////////////////////////////////
    /// Custom Sharing UI
    ///
    
    void ShowFacebookLoginView();
    
    void ShowTwitterAuthentication();
    
    bool FacebookIsAuthenticated();
    
    bool TwitterIsAuthenticated();
    
    bool YouTubeIsAuthenticated();
    
    void PerformFacebookLogout();
    
    void PerformYouTubeLogout();
    
    void SetNotificationsEnabled(bool notificationsEnabled);
    
    void FireTestNotification();
}

#endif
