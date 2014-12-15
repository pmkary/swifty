//
//  MathEvaluator.swift
//  Swifty
//
//  Created by Pouya Kary on 11/28/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

struct mathResult {
    
    var result : NSNumber = 0
    var itsNotACondition : Bool = true
    var doesItHaveErros = false
    
    init (number:NSNumber, itIsNotCondition:Bool) {
        self.result = number
        self.itsNotACondition = itIsNotCondition
    
    }
    
}

func mathEval (#stringExpression: String, inout #screen: codeScreen, inout #spaces: [String:NSNumber]) -> mathResult {
    
    if stringExpression.toInt() != nil { return mathResult(number: Double(stringExpression.toInt()!), itIsNotCondition: true) }
    
    
    let numberOfGeneralErrors = screen.errors.count
    
    var mathExpression = replacer(expressionString: stringExpression, spaces: spaces, screen: &screen)
   
    
    // checking for erros
    
    if screen.errors.count == numberOfGeneralErrors {
        
        // checks to see if it's a condition we're running
        var itsNotCondition = true
        for var i=0; i < mathExpression.utf16Count && itsNotCondition; i++ {
            let char:Character = mathExpression[i]
            if char == ">" || char == "<" || char == "=" { itsNotCondition = false }
        }
        
        // evaluates the expression
        var eval = DDMathEvaluator()
        var errors:NSError?
        var tokenizer = DDMathStringTokenizer(string: mathExpression, operatorSet:nil, error: &errors)
        var parser:DDParser = DDParser(tokenizer: tokenizer, error: &errors)
        var experssion:DDExpression! = parser.parsedExpressionWithError(&errors)
        var rewritten:DDExpression = DDExpressionRewriter.defaultRewriter().expressionByRewritingExpression(experssion, withEvaluator: eval)
        let result = eval.evaluateExpression(experssion, withSubstitutions: nil, error: &errors)
        
        if result == nil {
            var errorResult = mathResult(number: 0, itIsNotCondition: false)
            errorResult.doesItHaveErros = true
            return errorResult
        } else {
            return mathResult (number: result, itIsNotCondition: itsNotCondition)
        }
        
    } else {
    
        var errorResult = mathResult(number: 0, itIsNotCondition: false)
        errorResult.doesItHaveErros = true
        return errorResult
    }
}



