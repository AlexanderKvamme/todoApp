

import CoreGraphics

public struct DGElasticPullToRefreshConstants {
    
    struct KeyPaths {
        static let ContentOffset = "contentOffset"
        static let ContentInset = "contentInset"
        static let Frame = "frame"
        static let PanGestureRecognizerState = "panGestureRecognizer.state"
    }
    
    public static var WaveMaxHeight: CGFloat = 70.0
    public static var MinOffsetToPull: CGFloat = 95.0
    public static var LoadingContentInset: CGFloat = 0
    
    // Lets user set height of the little centered shown while loading.
    // - Should be equal to a cell size
    public static var loadingViewHeight: CGFloat = 75
    public static var loadingViewWidth: CGFloat = 75
}
