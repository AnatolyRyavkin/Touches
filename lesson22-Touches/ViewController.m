//
//  ViewController.m
//  lesson22-Touches
//
//  Created by Anatoly Ryavkin on 28/03/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property NSMutableArray* cells;
@property NSMutableArray* figurs;
@property UIView*field;
@property UIView*moveFigura;
@property CGPoint setPoint;
@property UIColor* color;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect= (CGRectGetWidth(self.view.frame) >= CGRectGetHeight(self.view.frame)) ? CGRectMake((CGRectGetWidth(self.view.frame)-CGRectGetHeight(self.view.frame))/2 ,0, CGRectGetHeight(self.view.frame),CGRectGetHeight(self.view.frame)) : CGRectMake(0, (CGRectGetHeight(self.view.frame)-CGRectGetWidth(self.view.frame))/2, CGRectGetWidth(self.view.frame),CGRectGetWidth(self.view.frame));
    self.field=[[UIView alloc]initWithFrame:rect];
    self.field.backgroundColor=[UIColor brownColor];
    self.field.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.field];
    self.cells=[[NSMutableArray alloc]init];
    self.figurs=[[NSMutableArray alloc]init];
    for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
           UIView*cell=[[UIView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.field.bounds)/8, j*CGRectGetHeight(self.field.bounds)/8,
                                                               CGRectGetWidth(self.field.bounds)/8, CGRectGetHeight(self.field.bounds)/8)];

            cell.backgroundColor=((i+j)%2==0) ? [UIColor blackColor] : [UIColor greenColor];
            [self.cells addObject:cell];
            [self.field addSubview:cell];
            UIView*fig=[[UIView alloc]init];
            if(j<3 && (i+j)%2==0){
                fig.frame=CGRectMake(i*CGRectGetWidth(self.field.bounds)/8+20, j*CGRectGetHeight(self.field.bounds)/8+20,
                                                                    CGRectGetWidth(self.field.bounds)/8-40, CGRectGetHeight(self.field.bounds)/8-40);
                fig.backgroundColor=[UIColor redColor];
                [self.figurs addObject:fig];
                [self.field addSubview:fig];
                
            }
            if(j>4 && (i+j)%2==0){
                fig.frame=CGRectMake(i*CGRectGetWidth(self.field.bounds)/8+20, j*CGRectGetHeight(self.field.bounds)/8+20,
                                                                   CGRectGetWidth(self.field.bounds)/8-40, CGRectGetHeight(self.field.bounds)/8-40);
                fig.backgroundColor=[UIColor blueColor];
                [self.figurs addObject:fig];
                [self.field addSubview:fig];
                
            }
           
        }
    }
}

-(void)touchesInvoking:(NSString*)nameTouche set: (NSSet*)set{
    NSMutableString*string=[NSMutableString stringWithString:nameTouche];
    for(UITouch*touche in set){
        CGPoint point =[touche locationInView:self.view];
        NSLog(@"toucehs mode - %@   coor: %@",string,NSStringFromCGPoint(point));
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    [self touchesInvoking:@"touchesBegin" set:touches];
    UITouch* touche=[touches anyObject];
    CGPoint point=[touche locationInView:self.field];
    NSLog(@"num=%d",[self.field pointInside:point withEvent:event]);
    for(UIView* figura in self.figurs){
         CGPoint point=[touche locationInView:figura];
        if([figura pointInside:point withEvent:event]){
            self.color=figura.backgroundColor;
            [self.field bringSubviewToFront:figura];
            CGPoint pointMove=[touche locationInView:figura];
            self.setPoint=CGPointMake((pointMove.x-0.5*figura.bounds.size.width), (pointMove.y-0.5*figura.bounds.size.height));
            self.moveFigura=figura;
            [UIView animateWithDuration:0.1 animations:^{
                figura.backgroundColor=[[UIColor yellowColor] colorWithAlphaComponent:0.8];
                figura.transform=CGAffineTransformMake(2, 0, 0, 2, 0, 0);
                [self.field bringSubviewToFront:figura];
                
            }];
        }
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
     [self touchesInvoking:@"touchesMoved" set:touches];
     if(self.moveFigura!=nil){
        UITouch* touche=[touches anyObject];
        [UIView animateWithDuration:0.3 animations:^{
            [self.field bringSubviewToFront:self.moveFigura];
            [self.view bringSubviewToFront:self.moveFigura];
            self.moveFigura.center=CGPointMake([touche locationInView:self.field].x-self.setPoint.x, [touche locationInView:self.field].y-self.setPoint.y);

        }];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
      [self touchesInvoking:@"touchesEnded" set:touches];
    [UIView animateWithDuration:0.2 animations:^{
        self.moveFigura.backgroundColor=[self.color colorWithAlphaComponent:1];
        self.moveFigura.transform=CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    }];
    UITouch* touche=[touches anyObject];
    CGPoint nearPoint=CGPointMake(0, 0);
    CGFloat distansMin=0;
    for(UIView*cell in self.cells){
        CGFloat dx= cell.center.x - [touche locationInView:self.field].x;
        CGFloat dy= cell.center.y - [touche locationInView:self.field].y;
        CGFloat distance= sqrt(dx*dx + dy*dy);
        if(distance<=distansMin || distansMin==0){
            int i=0;
            for(UIView*fig in self.figurs){
                if(cell.center.x==fig.center.x && cell.center.y==fig.center.y){
                    i++;
                }
            }
            if(i==0){
                 distansMin=distance;
                 nearPoint=cell.center;
            }
            
        }
    }
    self.moveFigura.center=nearPoint;
    self.moveFigura=nil;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
      [self touchesInvoking:@"touchesCancelled" set:touches];
      [self.moveFigura.layer removeAllAnimations];
      self.moveFigura=nil;
}

@end
