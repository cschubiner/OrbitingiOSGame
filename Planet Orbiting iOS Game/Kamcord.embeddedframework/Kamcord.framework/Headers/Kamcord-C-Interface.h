/*!
 *
 * Kamcord-C-Interface.h
 * Copyright (c) 2013 Kamcord. All rights reserved.
 *
 */

#ifndef __KAMCORD_C_INTERFACE_H__
#define __KAMCORD_C_INTERFACE_H__

#ifdef __cplusplus
extern "C" {
#endif
    /*******************************************************************
     *
     * Kamcord config
     *
     */
    
    /*
     *
     * Returns a C string which is the Kamcord version. You *must*
     * strdup this return value if you want to use it later.
     *
     */
    const char * Kamcord_Version();
    
    /*
     *
     * Automatically disable Kamcord on certain devices. Disabling Kamcord
     * on a device makes all medthod calls on those devices turn into NO-OPs.
     * Call this method before you call any other Kamcord methods.
     *
     * @param   disableiPod4G           Disable Kamcord on iPod1G, 2G, 3G, and 4G.
     * @param   disableiPod5G           Disable Kamcord on iPod5G.
     * @param   disableiPhone3GS        Disable Kamcord on iPhone 3GS.
     * @param   disableiPhone4          Disable Kamcord on iPhone 4.
     * @param   disableiPad1            Disable Kamcord on iPad 1.
     * @param   disableiPad2            Disable Kamcord on iPad 2.
     * @param   disableiPadMini         Disable Kamcord on iPad Mini.
     *
     */
    void Kamcord_SetDeviceBlacklist(bool disableiPod4G,
                                    bool disableiPod5G,
                                    bool disableiPhone3GS,
                                    bool disableiPhone4,
                                    bool disableiPad1,
                                    bool disableiPad2,
                                    bool disableiPadMini);
    
    /*
     *
     * Kamcord initialization. Must be called before you can start recording.
     *
     * @param   developerKey            Your Kamcord developer key.
     * @param   developerSecret         Your Kamcord developerSecret.
     * @param   appName                 The name of your application.
     * @param   parentViewController    The view controller that will present the Kamcord UI.
     *                                  This object must be an instance of UIViewController.
     *
     */
    void Kamcord_Init(const char * developerKey,
                      const char * developerSecret,
                      const char * appName,
                      void * parentViewController);
    
    
    /*
     *
     * Returns true if and only if Kamcord is enabled. Kamcord is by default
     * enabled, but is disabled if any of the following conditions are met:
     *
     *  - The version of iOS is < 5.0
     *  - The device has been blacklisted by Kamcord_SetDeviceBlacklist(...);
     *
     */
    bool Kamcord_IsEnabled();
    
    /*
     *
     * Enable or disable the live voice overlay.
     *
     * @param   enabled             Whether to enable or disable the live voiced overlay feature.
     *                              By default, this is disabled.
     *
     */
    void Kamcord_SetVoiceOverlayEnabled(bool eanbled);
    
    /*
     *
     * Returns true if live voice overlay has been enabled.
     *
     */
    bool Kamcord_VoiceOverlayEnabled();
    
    /*******************************************************************
     *
     * Video recording
     *
     */
    
    /*
     *
     * Start video recording.
     *
     */
	void Kamcord_StartRecording();
    
    /*
     *
     * Stop video recording.
     *
     */
    void Kamcord_StopRecording();
    
    /*
     *
     * Pause video recording.
     *
     */
    void Kamcord_Pause();
    
    /*
     *
     * Resume video recording.
     *
     */
    void Kamcord_Resume();
    
    /*
     *
     * Returns true if the video is recording. Note that there might be a slight
     * delay after you call Kamcord_StartRecording() before this method returns true.
     *
     */
    bool Kamcord_IsRecording();
    
    /*
     *
     * After every video is recorded (i.e. after you call StopRecording()), you should
     * call this method to set the title for the video in case it is shared.
     *
     * We suggest you set the title to contain some game-specific information such as
     * the level, score, and other relevant game metrics.
     *
     * @parama  title   The title of the last recorded video.
     *
     */
    void Kamcord_SetVideoTitle(const char * title);
    
    /*
     *
     * Set the level and score for the recorded video.
     * This metadata is used to rank videos in the watch view.
     *
     * @param   level   The level for the last recorded video.
     * @param   score   The score the user just achieved on the given level.
     *
     */
    void Kamcord_SetLevelAndScore(const char * level,
                                  double score);
    
    /*
     *
     * Use this to record the OpenGL frame to video in its currently rendered state.
     * You can use this, for instance, after you draw your game scene but before
     * you draw your HUD. This will result in the recorded video only having
     * the scene without the HUD.
     *
     */
    void Kamcord_CaptureFrame();
    
    /*
     *
     * Set the video quality to low, medium, or trailer. Please do *NOT* release your game
     * with trailer quality, as it makes immensely large videos with only a slight
     * video quality improvement over medium.
     *
     * The default and recommended quality seting is KC_MEDIUM_VIDEO_QUALITY.
     *
     * @param   quality     The desired video quality.
     *
     */
    typedef enum
    {
        KC_LOW_VIDEO_QUALITY        = 0,
        KC_MEDIUM_VIDEO_QUALITY     = 1,
        KC_TRAILER_VIDEO_QUALITY    = 2,    // Should only be used to make trailers. Do *NOT* release your game with this settings.
    } KC_VIDEO_QUALITY;
    
    void Kamcord_SetVideoQuality(KC_VIDEO_QUALITY videoQuality);
    
    /*******************************************************************
     *
     * Kamcord UI
     *
     */
    
    /*
     *
     * Show the Kamcord view, which will let the user share the most
     * recently recorded video.
     *
     */
    void Kamcord_ShowView();
    
    /*
     *
     * Show the watch view, which has a feed of videos shared by other users.
     *
     */
    void Kamcord_ShowWatchView();
    
    
    /*******************************************************************
     *
     * Share settings
     *
     */
    
    /*
     *
     * For native iOS 6 Facebook integration, set your Facebook App ID
     * so all Facebook actions will happen through your game's Facebook app.
     *
     * @param   facebookAppID   Your app's Facebook App ID.
     *
     */
    void Kamcord_SetFacebookAppID(const char * facebookAppID);
    
    /*
     *
     * Set the description for when the user shares to Facebook.
     *
     * @param   description     Your app's description when a user shares a video on Facebook.
     *
     */
    void Kamcord_SetFacebookDescription(const char * description);
    
    /*
     *
     * Set the video description and tags for YouTube.
     *
     * @param   description     The video's description when it's shared on YouTube.
     * @param   tags            The video's tags when it's shared on YouTube.
     *
     */
    void Kamcord_SetYouTubeSettings(const char * description,
                                    const char * tags);

    /*
     *
     * Set the default tweet.
     *
     * @param   tweet           The default tweet.
     *
     */
    void Kamcord_SetDefaultTweet(const char * tweet);
    
    /*
     *
     * The Twitter description for the embedded video.
     *
     * @param   twitterDescription  The twitter description for the embedded video.
     *
     */
    void Kamcord_SetTwitterDescription(const char * twitterDescription);

    /*
     *
     * Set the default email subject.
     *
     * @param   subject         The default subject if the user shares via email.
     *
     */
    void Kamcord_SetDefaultEmailSubject(const char * subject);

    /*
     *
     * Set the default email body.
     *
     * @param   body            The default email body if the user shares via email.
     *
     */
    void Kamcord_SetDefaultEmailBody(const char * body);
    
    
    /*******************************************************************
     * 
     * Sundry Methods
     *
     */
    
    /*
     *
     * Set the FPS of the recorded video. Valid values are 30 and 60 FPS.
     * The default setting is 30 FPS.
     *
     * @param   videoFPS        The recorded video's FPS.
     *
     */
    void Kamcord_SetVideoFPS(int videoFPS);
    
    /*
     *
     * Returns the FPS of the recorded video.
     *
     */
    int Kamcord_VideoFPS();
    
    /*
     *
     * To prevent videos from becoming too long, you can use this method
     * and Kamcord will only record the last given seconds of the video.
     *
     * For instance, if you set seconds to 300, then only the last 5 minutes
     * of video will be recorded and shared. The default setting is 300 seconds
     * with a maximum of up to 1 hour = 60 * 60 = 3600 seconds.
     *
     * @param   seconds         The maximum length of a recorded video.
     *
     */
    void Kamcord_SetMaximumVideoLength(unsigned int seconds);
    
    /*
     *
     * Returns the maximum video length.
     *
     */
    unsigned int Kamcord_MaximumVideoLength();
    
    /*******************************************************************
     *
     * Gameplay of the week
     *
     */
    
    /*
     *
     * Enable automatic gameplay of the week push notifications.
     *
     * @param   notificationsEnabled    Enable video push notifications?
     *
     */
    void Kamcord_SetNotificationsEnabled(bool notificationsEnabled);
    
    /*
     *
     * Fire a test gameplay of the week push notfication.
     *
     */
    void Kamcord_FireTestNotification();
#ifdef __cplusplus
}
#endif

#endif
