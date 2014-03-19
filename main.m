//
//  main.m
//  NCAA Tournament Simulator
//
//  Created by Devin Shelly on 3/18/14.
//  Copyright (c) 2014 Devin Shelly. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>

long double oddsFirstTeamWinsGame(NSDictionary *firstTeam, NSDictionary *secondTeam)
{
    long double pythag1 = [[firstTeam objectForKey:@"pythag"] doubleValue];
    long double pythag2 = [[secondTeam objectForKey:@"pythag"] doubleValue];
    
    return (pythag1-pythag1*pythag2) / (pythag1 + pythag2 - 2.0L * pythag1 * pythag2);
}

BOOL firstTeamWonGame(NSDictionary *firstTeam, NSDictionary *secondTeam)
{
    return oddsFirstTeamWinsGame(firstTeam, secondTeam) > (long double)drand48();
}

BOOL firstTeamWasFavored(NSDictionary *firstTeam, NSDictionary *secondTeam)
{
    double pythag1 = [[firstTeam objectForKey:@"pythag"] doubleValue];
    double pythag2 = [[secondTeam objectForKey:@"pythag"] doubleValue];
    
    return pythag1 > pythag2;
}

long double simulateBracket(NSArray *bracket, BOOL advanceFavorites, BOOL advanceUnderdogs)
{
    assert(!(advanceFavorites && advanceUnderdogs));
    NSMutableArray *bracketCopy = bracket.mutableCopy;
    
    /* Do playin games */
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[NSArray class]];
    }];
    NSArray *playinGames = [bracketCopy filteredArrayUsingPredicate:predicate];
    for (NSArray *playinGame in playinGames)
    {
        NSDictionary *firstTeam = [playinGame objectAtIndex:0];
        NSDictionary *secondTeam = [playinGame objectAtIndex:1];
        
        BOOL firstTeamWon = advanceFavorites ? firstTeamWasFavored(firstTeam, secondTeam) : advanceUnderdogs ? firstTeamWasFavored(secondTeam, firstTeam) : firstTeamWonGame(firstTeam, secondTeam);
        NSUInteger indexOfPlayinGame = [bracketCopy indexOfObjectIdenticalTo:playinGame];
        if (firstTeamWon)
        {
            [bracketCopy replaceObjectAtIndex:indexOfPlayinGame withObject:firstTeam];
        }
        else
        {
            [bracketCopy replaceObjectAtIndex:indexOfPlayinGame withObject:secondTeam];
        }
    }
    
    long double bracketProbability = 1.0;
    while (bracketCopy.count > 1)
    {
        for (NSUInteger i = 0; i<bracketCopy.count-1; i++)
        {
            NSDictionary *firstTeam = [bracketCopy objectAtIndex:i];
            NSDictionary *secondTeam = [bracketCopy objectAtIndex:i+1];
            
            BOOL firstTeamWon = advanceFavorites ? firstTeamWasFavored(firstTeam, secondTeam) : advanceUnderdogs ? firstTeamWasFavored(secondTeam, firstTeam) : firstTeamWonGame(firstTeam, secondTeam);
            if (firstTeamWon)
            {
                [bracketCopy removeObjectAtIndex:i+1];
                bracketProbability *= oddsFirstTeamWinsGame(firstTeam, secondTeam);
            }
            else
            {
                [bracketCopy removeObjectAtIndex:i];
                bracketProbability *= oddsFirstTeamWinsGame(secondTeam, firstTeam);
            }
        }
        
        if (bracketCopy.count == 4)
        {
            NSInteger seedSum = 0;
            for (NSDictionary *team in bracketCopy)
            {
                seedSum += [[team objectForKey:@"seed"] integerValue];
            }
        }
    }
    
    return bracketProbability;
}

int main(int argc, const char * argv[])
{
    srand48(time(NULL));
    @autoreleasepool {
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *teamsFilePath = [documentsDirectory stringByAppendingPathComponent:@"/NCAA Tournament Simulator/ncaateams.csv"];
        NSString *teamsString = [NSString stringWithContentsOfFile:teamsFilePath encoding:NSUTF8StringEncoding error:nil];
        NSMutableDictionary *teams = [NSMutableDictionary dictionaryWithCapacity:68];
        for (NSString *teamString in [teamsString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
        {
            NSArray *teamInfo = [teamString componentsSeparatedByString:@","];
            NSString *seed = [teamInfo objectAtIndex:0];
            NSString *name = [teamInfo objectAtIndex:1];
            double pythag = [[teamInfo objectAtIndex:2] doubleValue];
            NSNumber *pythagNumber = [NSNumber numberWithDouble:pythag];
            NSDictionary *teamDict = [NSDictionary dictionaryWithObjectsAndKeys:pythagNumber, @"pythag", name, @"name", seed, @"seed", nil];
            
            /* Playin games share a seed */
            if ([teams objectForKey:seed])
            {
                NSArray *playinGame = @[[teams objectForKey:seed], teamDict];
                [teams setObject:playinGame forKey:seed];
            }
            else
            {
                [teams setObject:teamDict forKey:seed];
            }
        }
        
        NSMutableArray *bracket = [NSMutableArray array];
        NSArray *regions = @[@"S", @"E", @"MW", @"W"];
        NSArray *seeds = @[@1, @16, @8, @9, @4, @13, @5, @12, @3, @14, @6, @11, @7, @10, @2, @15];
        for (NSString *region in regions)
        {
            for (NSNumber *seed in seeds)
            {
                NSString *seedAndRegion = [NSString stringWithFormat:@"%d%@", seed.intValue, region];
                [bracket addObject:[teams objectForKey:seedAndRegion]];
            }
        }
        
        long double allFavoritesProbability = simulateBracket(bracket, YES, NO);
        long double allUnderdogsProbability = simulateBracket(bracket, NO, YES);
        
        NSLog(@"The odds that the favorites win every game is 1 in %.0Lf", 1.0L/allFavoritesProbability);
        NSLog(@"The odds that the underdogs win every game is 1 in %.0Lf", 1.0L/allUnderdogsProbability);
        
        NSUInteger numSims = 1000000;
        NSMutableArray *outcomes = [NSMutableArray arrayWithCapacity:numSims];
        
        for (NSUInteger i = 0; i<numSims  ; i++)
        {
            if ((i+1)%(numSims/100) == 0)
            {
                NSLog(@"%lu", (i+1)/(numSims/100));
            }
            long double probability =  simulateBracket(bracket, NO, NO);
            [outcomes addObject:[NSNumber numberWithDouble:1.0/probability]];
        }
        
        [outcomes sortUsingSelector:@selector(compare:)];
        
        NSMutableString *csvoutcomes = [NSMutableString stringWithFormat:@"1 in x Outcome,\n"];
        [csvoutcomes appendString:[outcomes componentsJoinedByString:@",\n"]];
        
        NSString *outcomesFilePath = [documentsDirectory stringByAppendingPathComponent:@"/NCAA Tournament Simulator/ncaaoutcomes.csv"];
        [csvoutcomes writeToFile:outcomesFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    return 0;
}

