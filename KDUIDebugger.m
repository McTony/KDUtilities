//
//  KDUIDebugger.m
//  koudaixiang
//
//  Created by Blankwonder on 8/19/12.
//
//

#import "KDUIDebugger.h"
#import "KDLogger.h"

const char kIndentChar = '-';

void _KDUIDebuggerPrintSubviews(UIView *view, int indent);

void KDUIDebuggerPrintSubviews(UIView *view) {
    _KDUIDebuggerPrintSubviews(view, 0);
}

void _KDUIDebuggerPrintSubviews(UIView *view, int indent) {
#if DEBUG
    char *indentCStr = malloc(sizeof(char) * (indent + 1));
    for (int i = 0; i < indent; i++) {
        indentCStr[i] = kIndentChar;
    }
    indentCStr[indent] = '\0';
    NSString *indentStr = @(indentCStr);
    free(indentCStr);
    for (UIView *subview in view.subviews) {
        KDLog(@"%@%@: %@", indentStr, NSStringFromClass([subview class]), NSStringFromCGRect(subview.frame));
        _KDUIDebuggerPrintSubviews(subview, indent + 1);
    }
#endif
}