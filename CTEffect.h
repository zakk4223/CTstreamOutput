#import <CoreAudio/AudioHardware.h>
#import "CTContext.h"

@class CamTwist;

typedef enum
{
	CTEffectIdle,
	CTEffectInProgram,
	CTEffectInPreview,
	CTEffectInTransition
} CTEffectMode;

@interface CTEffect : NSObject
{
	CTContext			*context;
	CTEffectMode		ctemode;
	NSView				*inspector;
	NSView				*miniInspector;
	BOOL				enabled;
	BOOL				dirty;
	NSString			*name;
	NSString			*savedSetupName;
	NSString			*savedName;
}

// Determine the effect class from an encoded effect
+ (Class) effectClassWithCoder:(NSCoder *) coder;

// Factory method for creating effects from archives
+ (CTEffect *) effectWithCoder:(NSCoder *) coder;

// Implement this method to return YES if the effect is a video source
+ (BOOL) isSource;

// Implement this method to return YES if the effect is a video transition
+ (BOOL) isTransition;

// This method must be implemented for each effect
+ (NSString *) name;

// Both initializers must be implemented
- (id) initWithContext:(CTContext *) ctContext;
- (id) initWithCoder:(NSCoder *) coder;

// CTContext associated with this instance
- (CTContext *) context;

// Return a view to display in the settings pane
- (NSView *) inspectorView;

// Return a view to display under the Studio monitors
- (NSView *) miniInspector;

- (void) setNeedsPersist:(BOOL) b;
- (BOOL) isNeedsPersist;

// Convenience method for determining if a given instance is a video source
- (BOOL) isSource;

// Convenience method for determining if a given instance is a video transition
- (BOOL) isTransition;

// Convenience method for getting the effect name, which is overridable with setName
- (NSString *) name;
- (void) setName:(NSString *) name;

// Saved setup name.  Use for displayName
- (NSString *) savedSetupName;
- (void) setSavedSetupName:(NSString *) ssname;

// The display name.  Pretty much just the name + the saved setup (if any)
- (NSString *) displayName;

// Is the effect enabled
- (BOOL) isEnabled;

// If this effect produces audio, use this output device.
- (void) setAudioDevice:(AudioDeviceID) devId;

// Write the effect state into a coder
- (void) encodeWithCoder:(NSCoder *) coder;

// Wrapper around Defaults
- (void) setDefault:(id)value forKey:(NSString *)defaultName;
- (id) defaultForKey:(NSString *)defaultName;

// This method is called before each video frame cycle.
// You can assume the OpenGL frame is all yours.
- (void) preDoit;

// This method is called for each video frame
- (void) doit;

// Perform a transition
- (void) doTransitionTo:(CVOpenGLBufferRef) pbuff
			 percentage:(double) percentage;

// Set the mode.  Returns TRUE if the mode changed.
- (BOOL) setMode:(CTEffectMode) newMode;
- (CTEffectMode) mode;

// Property management.  (Experimental)
// For use with Scripting.  Name is display name and _not_ keypath.
- (NSArray *) effectProperties;
- (id) effectPropertyForName:(id) key;
- (void) setEffectProperty:(id) val 
					forName:(id) key;
- (NSDictionary *) propertyInfoForName:(id) key;

@end