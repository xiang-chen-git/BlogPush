platform :ios, "7.0"

link_with 'BlogIt', 'BlogIt_No_Ads'

def shared
	# Provides the sidebar menu
	pod 'CDRTranslucentSideBar', '>= 1.0.2'

	# Provides the zooming animation for our table view cells
	pod 'UITableViewZoomController', '>= 1.0.0'

	# Provides asynchronous image loading and caching
	pod 'SDWebImage', '>= 3.7.1'

	# Provides activity indicators for SDWebImages
	# Note: We're using a fork, as the original doesn't support the latest SDWebImage
	pod 'UIActivityIndicator-for-SDWebImage', :git => 'https://github.com/alphatroya/UIActivityIndicator-for-SDWebImage.git', :branch => 'master'

	# Provides a neat customizable refresh control
	# Note: We're using a patched version to overcome some layout issues
	pod 'CBStoreHouseRefreshControl', :git => 'https://github.com/hgia1234/CBStoreHouseRefreshControl.git', :branch => 'master'

	# Provides the splash animation framework
	# Note: The podspec is broken for this one, so we're using the head
	pod 'CBZSplashView', :head

	# Provides UIView popup functionality
	# Note: The podspec is broken for this one, so we're using the head
	pod 'KLCPopup', :head

	# Provides support for Parse and Parse's Push Notifications
	pod 'Parse', '>= 1.6.2'

	# Provides a simple loading indicator
	pod 'JGProgressHUD', '>= 1.2.3'
end

target 'BlogIt' do
	# Google AdMob SDK
	# NOTE: Requires AdSupport.framework, so if you don't use ads and get rejected,
	#		you need to disable the next line (add a #) and remove all code related
	#		related to Google AdMob yourself.
	pod 'Google-Mobile-Ads-SDK', '>= 7.0.0'

	shared
end

target 'BlogIt_No_Ads' do
	shared
end


