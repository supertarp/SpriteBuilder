/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2013 Apportable Inc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NodePhysicsBody.h"
#import "AppDelegate.h"
#import "PolyDecomposition.h"
#import "NSArray+Query.h"

#define kCCBPhysicsMinimumDefaultCircleRadius 16

@implementation NodePhysicsBody

- (id) initWithNode:(CCNode*) node
{
    self = [super init];
    if (!self)
    {
        return NULL;
    }

    [self setupDefaultPolygonForNode:node];
    
    _dynamic = !node.hasKeyframes;
    _affectedByGravity = YES;
    _allowsRotation = YES;
    
    _density = 1.0f;
    _friction = 0.3f;
    _elasticity = 0.3f;
    
    _collisionType = @"";
    _collisionMask = [NSMutableArray array];
    _collisionCategories = [NSMutableArray array];
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self)
    {
        return NULL;
    }

    // Shape
    _bodyShape = (CCBPhysicsBodyShape) [[ser objectForKey:@"bodyShape"] intValue];
    _cornerRadius = [[ser objectForKey:@"cornerRadius"] floatValue];
    
    // Points
    NSArray* serPoints = [ser objectForKey:@"points"];
    NSMutableArray* points = [NSMutableArray array];
    for (NSArray* serPt in serPoints)
    {
        CGPoint pt = CGPointZero;
        pt.x = [serPt[0] floatValue];
        pt.y = [serPt[1] floatValue];
        [points addObject:[NSValue valueWithPoint:pt]];
    }
    
    self.points = points;
    
    // Basic physics props
    _dynamic = [[ser objectForKey:@"dynamic"] boolValue];
    _affectedByGravity = [[ser objectForKey:@"affectedByGravity"] boolValue];
    _allowsRotation = [[ser objectForKey:@"allowsRotation"] boolValue];
    
    _density = [[ser objectForKey:@"density"] floatValue];
    _friction = [[ser objectForKey:@"friction"] floatValue];
    _elasticity = [[ser objectForKey:@"elasticity"] floatValue];
    
    _collisionType = [ser objectForKey:@"collisionType"];
    _collisionCategories = nil;
    _collisionMask = nil;
	
    if(_collisionType == nil)
    {
        _collisionType = @"";
    }
    
	id collisionCategoriesObject = [ser objectForKey:@"collisionCategories"];
    if(collisionCategoriesObject == nil)
    {
        _collisionCategories = [NSArray array];
    }
	//Fixup old data.
	else if([collisionCategoriesObject isKindOfClass:[NSString class]])
	{
		_collisionCategories = [collisionCategoriesObject componentsSeparatedByString:@";"];
	}
    else
    {
        _collisionCategories = collisionCategoriesObject;
    }
    
	
	id collisionMaskObject = [ser objectForKey:@"collisionMask"];
    if(collisionMaskObject == nil)
    {
        _collisionMask = [NSArray array];
    }
	//Fixup old data.
	else if([collisionMaskObject isKindOfClass:[NSString class]])
	{
		_collisionMask = [collisionMaskObject componentsSeparatedByString:@";"];
	}
    else
    {
        _collisionMask = collisionMaskObject;
    }
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    // Shape
    ser[@"bodyShape"] = @(_bodyShape);
    ser[@"cornerRadius"] = @(_cornerRadius);
    
    // Points
    NSMutableArray* serPoints = [NSMutableArray array];
    for (NSValue* val in _points)
    {
        CGPoint pt = [val pointValue];
        NSArray* serPt;
        serPt = @[@((float) pt.x),
                  @((float) pt.y)];
        [serPoints addObject:serPt];
    }
    ser[@"points"] = serPoints;
    
    //Polygons
    NSMutableArray * serPolygons = [NSMutableArray array];
    for (NSArray * polygon in _polygons) {
        
        NSMutableArray * serPolygon = [NSMutableArray array];
        for (NSValue* val in polygon)
        {
            CGPoint pt = [val pointValue];
            NSArray* serPt;
            serPt = @[@((float) pt.x),
                      @((float) pt.y)];
            [serPolygon addObject:serPt];
        }
        [serPolygons addObject:serPolygon];
    }
    ser[@"polygons"] = serPolygons;
    
    // Basic physics props
    ser[@"dynamic"] = @(_dynamic);
    ser[@"affectedByGravity"] = @(_affectedByGravity);
    ser[@"allowsRotation"] = @(_allowsRotation);

    ser[@"density"] = @(_density);
    ser[@"friction"] = @(_friction);
    ser[@"elasticity"] = @(_elasticity);
    
    if(_collisionType == nil)
    {
        _collisionType = @"";
    }
    
    if(_collisionCategories == nil)
    {
        _collisionCategories = [NSArray array];
    }
    
    if(_collisionMask == nil)
    {
        _collisionMask = [NSArray array];
    }

    ser[@"collisionType"] = _collisionType;
    ser[@"collisionCategories"] = _collisionCategories;
    ser[@"collisionMask"] = _collisionMask;

    return ser;
}

- (void) setupDefaultPolygonForNode:(CCNode*) node
{
    _bodyShape = kCCBPhysicsBodyShapePolygon;
    self.cornerRadius = 0;
    
    float w = (float) node.contentSize.width;
    float h = (float) node.contentSize.height;
    
    if (w == 0)
    {
        w = 32;
    }
    if (h == 0)
    {
        h = 32;
    }
    
    // Calculate corners
    CGPoint a = ccp(0, 0);
    CGPoint b = ccp(0, h);
    CGPoint c = ccp(w, h);
    CGPoint d = ccp(w, 0);
    
    self.points = @[[NSValue valueWithPoint:a],
                    [NSValue valueWithPoint:b],
                    [NSValue valueWithPoint:c],
                    [NSValue valueWithPoint:d]];
}

- (void) setupDefaultCircleForNode:(CCNode*) node
{
    _bodyShape = kCCBPhysicsBodyShapeCircle;
    
    float radius = (float) MAX(node.contentSize.width/2, node.contentSize.height/2);
    if (radius < kCCBPhysicsMinimumDefaultCircleRadius) radius = kCCBPhysicsMinimumDefaultCircleRadius;
    
    self.cornerRadius = radius;
    
    float w = (float) node.contentSize.width;
    float h = (float) node.contentSize.height;
    
    self.points = @[[NSValue valueWithPoint:ccp(w / 2, h / 2)]];
}

- (void) setBodyShape:(CCBPhysicsBodyShape)bodyShape
{
    if (bodyShape == _bodyShape) return;
    
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*bodyShape"];
    _bodyShape = bodyShape;
    
    if (bodyShape == kCCBPhysicsBodyShapePolygon)
    {
        [self setupDefaultPolygonForNode:[AppDelegate appDelegate].selectedNode];
    }
    else if (bodyShape == kCCBPhysicsBodyShapeCircle)
    {
        [self setupDefaultCircleForNode:[AppDelegate appDelegate].selectedNode];
    }
}

- (void) setCornerRadius:(float)cornerRadius
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*cornerRadius"];
    _cornerRadius = cornerRadius;
}

- (void) setPoints:(NSArray *)points
{
    if (points == _points) return;
    _points = points;
    
    if(points && _bodyShape == kCCBPhysicsBodyShapePolygon)
    {
        NSArray * outputPolygons;
        if(![PolyDecomposition bayazitDecomposition:points outputPoly:&outputPolygons])
        {
            self.polygons = @[[PolyDecomposition makeConvexHull:points]];
        }
        else
        {
            self.polygons = outputPolygons;
        }
    }
    else
    {
        self.polygons = nil;
    }
}

- (void) setDynamic:(BOOL)dynamic
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*dynamic"];
    _dynamic = dynamic;
}

- (void) setAffectedByGravity:(BOOL)affectedByGravity
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*affectedByGravity"];
    _affectedByGravity = affectedByGravity;
}

- (void) setAllowsRotation:(BOOL)allowsRotation
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*allowsRotation"];
    _allowsRotation = allowsRotation;
}

- (void) setDensity:(float)density
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*density"];
    _density = density;
}

- (void) setFriction:(float)friction
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*friction"];
    _friction = friction;
}

- (void) setElasticity:(float)elasticity
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*elasticity"];
    _elasticity = elasticity;
}

- (void)setCollisionMask:(NSArray *)collisionMask
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*collisionMask"];
    _collisionMask = collisionMask;
}

- (void)setCollisionCategories:(NSArray *)collisionCategories
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*collisioncollisionCategories"];
    _collisionCategories = collisionCategories;
}

- (void)setCollisionType:(NSString *)collisionType
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*collisionType"];
    _collisionType = collisionType;
}

@end
