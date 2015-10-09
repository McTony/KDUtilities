//
//  KDUIDebugger.m
//  koudaixiang
//
//  Created by Blankwonder on 8/19/12.
//
//

#import <objc/runtime.h>
#import "KDDebugger.h"
#import "KDLogger.h"

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

static void _KDDebuggerPrintSubviews(UIView *view, int indent) {
#if DEBUG
    char *indentCStr = malloc(sizeof(char) * (indent + 1));
    for (int i = 0; i < indent; i++) {
        indentCStr[i] = '-';
    }
    indentCStr[indent] = '\0';
    NSString *indentStr = @(indentCStr);
    free(indentCStr);
    for (UIView *subview in view.subviews) {
        KDLog(@"KDUIDebugger", @"%@%@: %@", indentStr, NSStringFromClass([subview class]), NSStringFromCGRect(subview.frame));
        _KDDebuggerPrintSubviews(subview, indent + 1);
    }
#endif
}

void KDDebuggerPrintSubviews(UIView *view) {
    _KDDebuggerPrintSubviews(view, 0);
}

#endif

void KDDebuggerDumpObjcMethods(Class clz) {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    KDLog(@"KDUIDebugger", @"Found %d methods on '%s'", methodCount, class_getName(clz));
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        KDLog(@"KDUIDebugger", @"'%s' of encoding '%s'",
               sel_getName(method_getName(method)),
               method_getTypeEncoding(method));
    }
    
    free(methods);
}