#!/usr/bin/env python3

import urllib.request
import urllib.parse
import json

biblioURL = "https://gateway.bibliocommons.com/v2/libraries/"

infile = 'fodder'
libraries = ['multcolib']   # 'wccls', etc
books = []



###libraries.append('multcolib')
###libraries.append()

# Read the list of books to search for
file = open(infile, 'r')
for line in file.readlines():
    books.append(line.split('/'))


for book in books:
    bookInfo = { 'title': book[0], 'author': book[1], 'libraries':[] }

    for lib in libraries:

        # assemble a search url
        url_start = biblioURL + lib + "/bibs/search?query="
        query = "(title:(" + book[0] + ") AND contributor:(" + book[1] + ")"
        url_end = ")&searchType=bl"
        url = url_start + urllib.parse.quote(query) + url_end
        ###print( url )

        # Read the results page into a python dictionary
        f = urllib.request.urlopen( url )
        bookinfo = f.read()
        t = json.loads(bookinfo)
        bibs = t['entities']['bibs']

        copyList = [];
        for key in bibs:
            info  = bibs[key]['briefInfo']
            copies = bibs[key]['availability']

            # if we don't have a description for this book yet, use this one.
            if 'desc' not in bookInfo:
                bookInfo['desc'] = info['description']

            # Copy and save the info on this library's copies of this book
            copyList.append( { 'format': info['format'],
                               'total': copies['totalCopies'],
                               'avail': copies['availableCopies'],
                               'held':  copies['heldCopies'] } )

        bookInfo['libraries'].append( { lib: copyList } )

    # Print out all the info for this book
    print(f"{bookInfo['title']}, by {bookInfo['author']}" )
    print()
    print( bookInfo['desc'] )
    print()

    for library in bookInfo['libraries']:
        for key in library:
            print( key + ":" )
            for x in library[key]:
                print(f"{x['format']}: {x['avail']} of {x['total']} available, {x['held']} on hold"  )
            print()
           
        

        

            
# code to read likely info from a library's top page
#        f = urllib.request.urlopen( biblioURL+lib )
#        toppage = f.read()
#        t = json.loads(toppage)
#        id = t['library']['id']
#        longName = t['entities']['libraries'][str(id)]['longName']
#        shortName = t['entities']['libraries'][str(id)]['shortName']
#        print( id )
#        print( shortName )
#        print( longName )


        
#https://gateway.bibliocommons.com/v2/libraries/multcolib/bibs/search?query=(title%3A(Playground)%20AND%20contributor%3A(Richard%20Powers)%20)&searchType=bl

#.../bibs/search?query=monmouth&searchType=smart
#...?query=(title%3A(...)%20AND%20contributor%3A(...)%20)&searchType=bl
