#!/usr/bin/env python
####################################################################
# Instantiates a template containing specific keyword tokens.  The
# keyword tokens will be exchanged for the actual values when the
# template file is created.
# 
# Command line parameters:
# @param 1 is the values file containing the values to fill in
# @param 2 is the template file containing keywords to replace
# @param 3 is the file to create from the template instatiation
#
# All values for the template instantiation are specified in the form: 
#     TEMPLATED_VALUE = value
#
# This makes it convenient to use bash variable files for the template
# input.  The corresponding template file will use "TEMPLATED_VALUE"
# wherever it requires a templated value.
#
####################################################################

import sys

####################################################################
# Reads a template token file to create tuples of tokens.
# @return: token tuple array with element: (token name, token value)
#
# File format of the tuples are:
#    # comment/ignored
#    tokenName = tokenValue
#    ...

def getTokenValuesFromFile(tokenValueFilename):
    tokenValueFile = open(tokenValueFilename, "r")
    tokenTuples = []
    for tokenText in tokenValueFile:
        # remove whitespace
        tokenText = tokenText.strip()
        
        # ignore comment characters
        isComment = tokenText.startswith("#");
        if isComment:
            continue
            
        # break up the text into the token fields (name, value)        
        tokenTuple = parseForToken(tokenText)
        if tokenTuple != None:
            tokenTuples.append(tokenTuple)

    return tokenTuples


####################################################################
# Creates a substituted instance of a template file using the token
# values to replace each occurrence of a token within the template.

def instantiateTemplate(templateFilename, instantiationFilename, tokenTuples):
    templateFile = open(templateFilename, "r")
    instantiateFile = open(instantiationFilename, "w")
    
    # perform substitution for each line in template
    for templateText in templateFile:
        substitutedText = substituteTokens(templateText, tokenTuples)
        instantiateFile.write(substitutedText)
        
    templateFile.close()


####################################################################
# Substitutes any matching token in the targetString with the value
# @return: substituted string

def substituteTokens(targetString, tokenTuples):
    # cycle through all available tokens and replace inside the targetString
    for tokenIndex in range(0, len(tokenTuples)):
        currentTokenName, currentTokenValue = tokenTuples[tokenIndex]
        targetString = targetString.replace(currentTokenName, currentTokenValue)

    return targetString    


####################################################################
# Parses the following string to retrieve a 
# @return: tuple with the name, value of the token or None if 
#     it does not contain one

def parseForToken(text):
    tokenFields = text.split("=")
    
    # if the fields were found then return them
    if len(tokenFields) > 1:
        tokenName = tokenFields[0]
        tokenValue = tokenFields[1]

        # remove whitespace surrounding the fields
        tokenName = tokenName.strip()
        tokenValue = tokenValue.strip()
     
        return tokenName, tokenValue
    else:
        return None

####################################################################

def main():
    # grab command line arguments
    if len(sys.argv) != 4:
        return -1
    valuesFilename = sys.argv[1]
    templateFilename = sys.argv[2]
    instantiationFilename = sys.argv[3]

    # create the values for the template and generate new instantiation
    tokenTuples = getTokenValuesFromFile(valuesFilename)
    instantiateTemplate(templateFilename, instantiationFilename, tokenTuples)

# Run as the main program
if __name__ == '__main__':
    main()
