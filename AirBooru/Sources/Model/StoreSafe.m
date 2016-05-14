//
// Created by qii on 7/28/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "StoreSafe.h"


@implementation StoreSafe

+ (NSArray *)dangerousTags {
    NSArray *words = @[@"swimsuit", @"swimsuits", @"underwear", @"nude", @"cleavage", @"nipples",
            @"naked", @"bathing", @"ass", @"penis", @"no_bra", @"bikini", @"breasts", @"pantsu", @"seifuku", @"uniform",
            @"wet", @"erect_nipples", @"bra", @"censored", @"breast_hold", @"lingerie", @"cameltoe", @"skirt_lift", @"underboob",
            @"panty_pull", @"shimapan", @"topless", @"bottomless", @"string_panties", @"horns", @"wet_clothes", @"kimono",
            @"sex", @"feet", @"pussy_juice", @"pussy", @"anus", @"garter_belt", @"paper_texture", @"cream", @"naked_apron",
            @"bunny_girl", @"onsen", @"thong", @"kitsune", @"buruma", @"dress_shirt", @"nipple_slip", @"queen's_blade",
            @"devil", @"ass_grab", @"screening", @"shuz", @"yaoi", @"npn", @"blood", @"tokyo ghoul"];
    return words;
}

+ (NSArray *)dangerousIds {
    NSArray *words = @[@136606, @136424, @137185, @132972, @135417, @130444, @260418, @167033, @136606,
            @137185, @139727, @136424, @135704, @130598, @131672, @127384, @125193, @122754, @122250, @143461, @276367,
            @152916, @143906, @130704, @113323, @110045, @72723, @72715, @57402, @54020, @49152, @29389, @29374, @29372,
            @124980, @69008, @306854, @302603, @300346, @300330, @291884, @283014, @282342, @278530, @278529, @275287, @241391, @11912,
            @30255, @58750];
    return words;
}

+ (NSArray *)safeTags {
    NSArray *words = @[@"akame", @"maid", @"touhou", @"animal ears", @"weapon", @"gun", @"neko"];
    return words;
}

@end