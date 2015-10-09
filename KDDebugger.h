//
//  KDUIDebugger.h
//  koudaixiang
//
//  Created by Blankwonder on 8/19/12.
//
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
void KDUIDebuggerPrintSubviews(UIView *view);
#endif

void KDDebuggerDumpObjcMethods(Class clz);