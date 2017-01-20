module ButtonTest;


import std.container.array;
import std.stdio;
import std.algorithm;
import std.ascii;
//import std.exception;
import std.string;
import std.traits;
import std.conv;
import std.file;
import std.path;
import std.format;
import std.math;

import core.stdc.stdlib; 

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;

enum TEST_IMAGE_SIZE = 20;

// 20x20 8-bit
private const(ubyte)[] image_data_8 = [
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
];

// 20x20 8-bit
private const(ubyte)[] image_data_8_pressed = [
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,5,1,1,1,1,1,2,2,2,2,2,5,0,0,0,5, 
    5,0,0,0,1,5,1,1,1,1,2,2,2,2,5,2,0,0,0,5, 
    5,0,0,0,1,1,5,1,1,1,2,2,2,5,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,5,1,1,2,2,5,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,5,1,2,5,2,2,2,2,0,0,0,5, 
    5,0,0,0,1,1,1,1,1,5,5,2,2,2,2,2,0,0,0,5, 
    5,0,0,0,3,3,3,3,3,5,5,4,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,3,5,3,4,5,4,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,3,5,3,3,4,4,5,4,4,4,0,0,0,5, 
    5,0,0,0,3,3,5,3,3,3,4,4,4,5,4,4,0,0,0,5, 
    5,0,0,0,3,5,3,3,3,3,4,4,4,4,5,4,0,0,0,5, 
    5,0,0,0,5,3,3,3,3,3,4,4,4,4,4,5,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
];

// 20x20 8-bit
private const(ubyte)[] image_data_8_inactive = [
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,5,5,1,1,1,1,1,1,1,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
    5,0,0,0,5,5,1,1,1,1,1,1,1,5,5,5,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
    5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
];


// 20x20 24-bit
private const(ubyte)[] image_data_24 = [
    000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
    000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
    000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
];

// 20x20 32-bit
private const(ubyte)[] image_data_32 = [
    000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
    000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255
];


// 16x16 32-bit
private const(ubyte)[] image_FileSave = [
    255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 183, 182, 245, 255, 183, 182, 245, 255, 179, 178, 243, 255, 174, 173, 241, 255, 168, 167, 238, 255, 162, 161, 234, 255, 155, 154, 231, 255, 148, 147, 228, 255, 143, 142, 224, 255, 136, 135, 221, 255, 129, 128, 218, 255, 123, 122, 214, 255, 117, 116, 211, 255, 112, 111, 209, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 179, 178, 243, 255, 190, 189, 255, 255, 147, 146, 248, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 75, 88, 190, 255, 89, 88, 176, 255, 89, 88, 176, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 173, 172, 240, 255, 190, 189, 255, 255, 138, 137, 239, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 63, 82, 184, 255, 51, 51, 103, 255, 86, 85, 170, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 167, 166, 237, 255, 190, 189, 255, 255, 129, 128, 230, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 52, 77, 179, 255, 122, 121, 223, 255, 83, 82, 164, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 159, 158, 233, 255, 190, 189, 255, 255, 119, 118, 220, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 40, 71, 173, 255, 114, 113, 215, 255, 80, 79, 159, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 152, 151, 229, 255, 190, 189, 255, 255, 110, 109, 211, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 198, 209, 229, 255, 28, 65, 167, 255, 103, 103, 204, 255, 77, 77, 154, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 146, 145, 226, 255, 190, 189, 255, 255, 103, 102, 204, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 198, 209, 229, 255, 189, 202, 225, 255, 17, 59, 161, 255, 92, 93, 194, 255, 74, 74, 148, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 139, 138, 223, 255, 188, 187, 255, 255, 183, 182, 255, 255, 96, 99, 201, 255, 86, 94, 196, 255, 75, 88, 190, 255, 63, 82, 184, 255, 52, 77, 179, 255, 40, 71, 173, 255, 28, 65, 167, 255, 17, 59, 161, 255, 92, 93, 193, 255, 84, 86, 186, 255, 71, 71, 143, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 132, 131, 219, 255, 180, 179, 255, 255, 174, 173, 255, 255, 164, 163, 252, 255, 143, 142, 244, 255, 135, 134, 236, 255, 129, 128, 230, 255, 122, 121, 223, 255, 114, 113, 215, 255, 108, 107, 209, 255, 92, 93, 193, 255, 84, 86, 186, 255, 76, 80, 178, 255, 68, 68, 137, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 124, 123, 215, 255, 170, 169, 255, 255, 160, 159, 251, 255, 148, 147, 245, 255, 75, 91, 113, 255, 75, 91, 113, 255, 75, 91, 113, 255, 75, 91, 113, 255, 82, 98, 118, 255, 91, 106, 125, 255, 84, 86, 186, 255, 76, 79, 178, 255, 68, 73, 170, 255, 65, 65, 131, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 118, 117, 212, 255, 160, 159, 255, 255, 145, 144, 245, 255, 135, 134, 236, 255, 75, 91, 113, 255, 0, 0, 0, 255, 52, 60, 71, 255, 206, 217, 233, 255, 212, 221, 236, 255, 103, 116, 133, 255, 67, 75, 174, 255, 68, 73, 170, 255, 60, 66, 163, 255, 62, 62, 125, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 112, 111, 209, 255, 154, 153, 255, 255, 135, 134, 236, 255, 129, 128, 230, 255, 75, 91, 113, 255, 52, 60, 71, 255, 104, 120, 141, 255, 216, 224, 237, 255, 224, 231, 241, 255, 115, 127, 143, 255, 53, 65, 163, 255, 60, 66, 162, 255, 53, 61, 156, 255, 60, 59, 120, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 108, 107, 207, 255, 143, 142, 243, 255, 129, 128, 230, 255, 36, 68, 170, 255, 33, 50, 71, 255, 171, 180, 195, 255, 179, 187, 198, 255, 188, 193, 202, 255, 196, 200, 206, 255, 72, 77, 86, 255, 51, 62, 158, 255, 54, 61, 156, 255, 49, 57, 152, 255, 57, 57, 114, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 108, 107, 207, 84, 101, 100, 195, 255, 86, 85, 170, 255, 83, 82, 164, 255, 80, 79, 159, 255, 77, 77, 154, 255, 74, 74, 148, 255, 71, 71, 143, 255, 68, 68, 137, 255, 65, 65, 131, 255, 60, 59, 120, 255, 60, 59, 120, 255, 57, 57, 114, 255, 55, 54, 110, 255, 255,  0, 255, 255,
    255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255, 0, 255, 255
];

public class ButtonTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupButton button = new IupButton();
        button.title = "&OK";
        button.name = "button0";
        button.click += &okButton_click;

        IupVbox box1 = new IupVbox();
        box1.margin = Size(5, 5);
        box1.gap = 5;
        box1.backgroundColor = Color.fromRgb(75, 150, 170);
        //box1.padding = Size(15, 15);
        box1.append(button);

        //
        button = new IupButton();
        button.title = "&Text && Test(按钮)";
        button.tooltip.text = "Button & Tip";
        //button.padding = Size(15, 15);
        //button.backgroundColor = Color.fromRgb(128, 128, 255);
        //button.size = Size(40, 40);
        //button.canExpand = true;
        button.foregroundColor = Color.fromRgb(0, 0, 255);
        //button.rasterSize = Size(200, 100);
        //button.canFocus = false;
        //button.textAlignment = ContentAlignment.MiddleCenter;
        button.textAlignment = ContentAlignment.TopLeft;
        button.name = "button1";
        setCallback(button);

        box1.append(button);

        // 
        button = new IupButton();
        button.title = "Text1\nSecond Line";
        //button.rasterSize = Size(200, 100);
        button.textAlignment = ContentAlignment.MiddleCenter;
        button.font = Font.parse("Helvetica, Underline 14");
        button.isFlat = true;
        button.name = "button2";
        setCallback(button);

        box1.append(button);

        // 
        button = new IupButton();
        button.title = "Text2\n<b>Second Line</b>";
        button.rasterSize = Size(200, 100);
        button.textAlignment = ContentAlignment.BottomRight;
        //button.canMarkup = true;
        button.canFocus = false;
        button.name = "button3";
        setCallback(button);

        box1.append(button);

        // 
        button = new IupButton();
        button.rasterSize = Size(30, 30);
        button.backgroundColor = Color.fromRgb(255, 128, 92);
        button.name = "color";
        setCallback(button);

        box1.append(button);

        // 
        IupVbox box2 = new IupVbox();
        box2.margin = Size(5, 5);
        box2.gap = 5;

        // 
        button = new IupButton();
        button.title = "Images";
        button.image = new IupImage32(16, 16, image_FileSave);

        box2.append(button);

        //
        IupImage8 image1 = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8);
        Color background = image1.background;
        image1.setColor(0, background);
        //image1.useBackground(0);
        image1.setColor(1, Color.fromRgb(255, 0, 0));
        image1.setColor(2, Color.fromRgb(0, 255, 0));
        image1.setColor(3, Color.fromRgb(0, 0, 255));
        image1.setColor(4, Color.fromRgb(255, 255, 255));
        image1.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1i = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_inactive);
        background = image1i.background;
        image1i.setColor(0, background);
        //image1i.useBackground(0);
        image1i.setColor(1, Color.fromRgb(255, 0, 0));
        image1i.setColor(2, Color.fromRgb(0, 255, 0));
        image1i.setColor(3, Color.fromRgb(0, 0, 255));
        image1i.setColor(4, Color.fromRgb(255, 255, 255));
        image1i.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1p = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_pressed);
        background = image1p.background;
        image1p.setColor(0, background);
        //image1p.useBackground(0);
        image1p.setColor(1, Color.fromRgb(255, 0, 0));
        image1p.setColor(2, Color.fromRgb(0, 255, 0));
        image1p.setColor(3, Color.fromRgb(0, 0, 255));
        image1p.setColor(4, Color.fromRgb(255, 255, 255));
        image1p.setColor(5, Color.fromRgb(0, 0, 0));

        //
        button = new IupButton();
        //button.title = "Text1";
        //button.image = IupImages.Tecgraf;
        //button.imagePosition = ImagePosition.Bottom;
        button.image = image1;
        button.imageInactive = image1i;
        button.imagePressed = image1p;
        button.tooltip.text  = "Image Button";
        button.name = "button4";
        button.padding = Size(5, 5);
        setCallback(button);

        box2.append(button);


        //
        IupImage24 image2 = new IupImage24(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_24);
        button = new IupButton();
        button.image = image2;
        button.isFlat = true;
        button.canFocus = false;
        button.padding = Size(10, 10);
        button.name = "button5";
        setCallback(button);

        box2.append(button);

        //
        IupImage32 image3 = new IupImage32(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_32);
        button = new IupButton();
        button.image = image3;
        button.title = "Text3";
        button.name = "button6";
        setCallback(button);

        box2.append(button);

        //
        IupSeparator separator = new IupSeparator();
        separator.orientation = Orientation.Vertical;

        IupHbox box3 = new IupHbox();
        box3.append(box1,separator, box2);


        this.child = box3;
        this.title = "IupButton Test";
    }

    private void setCallback(IupButton button)
    {
        button.click += &button_click;
        button.mouseEnter += &button_mouseEnter;
        button.mouseLeave += &button_mouseLeave;
        button.helpRequested += &button_helpRequested;
        button.gotFocus += &button_gotFocus;
        button.lostFocus += &button_lostFocus;
        button.keyPress += &button_keyPress;
    }

    private void button_keyPress(Object sender, CallbackEventArgs e, int key)
    {
        IupElement element = cast(IupElement)sender;

        if(isPrintable(key))
        {
            writefln("keyPress(%s, %d = %s \'%c\')", element.name, key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("keyPress(%s, %d = %s)", element.name, key, Keys.toName(key));
        }

        writefln("ModifierKeyState(%s)", Keys.getModifierKeyState()); 
    }


    private void button_lostFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("lostFocus(%s)", element.name); 
    }

    private void button_gotFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("gotFocus(%s)", element.name); 
    }

    private void button_helpRequested(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HelpRequested(%s)", element.name); 
    }

    private void okButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
        m_isActive = !m_isActive;
        this.child.isAcitve = m_isActive;
        button.enabled = true;
    }
    private bool m_isActive = true;

    private void button_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
        writefln("ACTION(%s) - %d", button.name, count); 
        count++;
    }

    private void button_mouseEnter(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseEnter(%s)", element.name); 
    }

    private void button_mouseLeave(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseLeave(%s)", element.name); 
    }


    private int count = 1;

    
}


public class FlatButtonTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        bool isToggle = false;

        IupFlatButton button = new IupFlatButton();
        button.title = "_@IUP_OK";
        button.name = "button0";
        button.click += &okButton_click;

        IupVbox box1 = new IupVbox();
        box1.margin = Size(5, 5);
        box1.gap = 5;
        //box1.background = Color.fromRgb(75, 150, 170);
        //box1.padding = Size(15, 15);
        box1.append(button);

        //
        button = new IupFlatButton();
        button.title = "Test(按钮)";
        button.tooltip.text = "Button & Tip";
        //button.padding = Size(15, 15);
        //button.background = Color.fromRgb(128, 128, 255);
        //button.size = Size(40, 40);
        //button.canExpand = true;
        //button.foreground = Color.fromRgb(0, 0, 255);
        //button.rasterSize = Size(200, 100);
        //button.canFocus = false;
        button.textAlignment = ContentAlignment.MiddleCenter;
        //button.textAlignment = ContentAlignment.TopLeft;
        button.name = "button1";
        button.isToggle = isToggle;
        setCallback(button);

        box1.append(button);

        // 
        button = new IupFlatButton();
        button.title = "Text1\nSecond Line";
        button.rasterSize = Size(200, 100);
        button.textAlignment = ContentAlignment.MiddleCenter;
        button.font = Font.parse("Helvetica, Underline 14");
        button.name = "button2";
        button.isToggle = isToggle;
        setCallback(button);

        box1.append(button);

        // 
        button = new IupFlatButton();
        button.title = "Text2\n<b>Second Line</b>";
        button.rasterSize = Size(200, 100);
        button.textAlignment = ContentAlignment.BottomRight;
        //button.canMarkup = true;
        button.canFocus = false;
        button.name = "button3";
        button.isToggle = isToggle;
        setCallback(button);

        box1.append(button);

        // 
        button = new IupFlatButton();
        button.rasterSize = Size(30, 30);
        button.foregroundColor = Color.fromRgb(255, 128, 92);
        button.name = "color";
        button.isToggle = isToggle;
        setCallback(button);

        box1.append(button);

        // 
        IupVbox box2 = new IupVbox();
        box2.margin = Size(5, 5);
        box2.gap = 5;

        // 
        button = new IupFlatButton();
        button.title = "Images";
        button.image = new IupImage32(16, 16, image_FileSave);

        box2.append(button);

        //
        IupImage8 image1 = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8);
        Color background = image1.background;
        image1.setColor(0, background);
        //image1.useBackground(0);
        image1.setColor(1, Color.fromRgb(255, 0, 0));
        image1.setColor(2, Color.fromRgb(0, 255, 0));
        image1.setColor(3, Color.fromRgb(0, 0, 255));
        image1.setColor(4, Color.fromRgb(255, 255, 255));
        image1.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1i = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_inactive);
        background = image1i.background;
        image1i.setColor(0, background);
        //image1i.useBackground(0);
        image1i.setColor(1, Color.fromRgb(255, 0, 0));
        image1i.setColor(2, Color.fromRgb(0, 255, 0));
        image1i.setColor(3, Color.fromRgb(0, 0, 255));
        image1i.setColor(4, Color.fromRgb(255, 255, 255));
        image1i.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1p = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_pressed);
        background = image1p.background;
        image1p.setColor(0, background);
        //image1p.useBackground(0);
        image1p.setColor(1, Color.fromRgb(255, 0, 0));
        image1p.setColor(2, Color.fromRgb(0, 255, 0));
        image1p.setColor(3, Color.fromRgb(0, 0, 255));
        image1p.setColor(4, Color.fromRgb(255, 255, 255));
        image1p.setColor(5, Color.fromRgb(0, 0, 0));

        //
        button = new IupFlatButton();
        button.title = "Text";
        button.image = IupImages.Tecgraf;
        //button.imagePosition = ImagePosition.Bottom;
        //button.image = image1;
        //button.imageInactive = image1i;
        //button.imagePressed = image1p;
        button.tooltip.text  = "Image Label";
        button.name = "button4";
        button.padding = Size(5, 5);
        setCallback(button);

        box2.append(button);


        //
        IupImage24 image2 = new IupImage24(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_24);
        button = new IupFlatButton("Text2");
        button.image = image2;
        button.imagePosition = Position.Top;
        button.canFocus = false;
        button.padding = Size(15, 15);
        button.isToggle = true;
        button.isChecked = false;
        button.name = "button5";
        setCallback(button);

        box2.append(button);

        //
        IupImage32 image3 = new IupImage32(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_32);
        button = new IupFlatButton();
        button.image = image3;
        button.title = "Text3";
        button.name = "button6";
        setCallback(button);

        box2.append(button);

        //
        IupSeparator separator = new IupSeparator();
        separator.orientation = Orientation.Vertical;

        IupHbox box3 = new IupHbox();
        box3.append(box1,separator, box2);


        this.child = box3;
        this.title = "IupFlatButton Test";
        this.startFocus = button;
    }

    private void setCallback(IupFlatButton button)
    {
        button.click += &button_click;
        button.mouseEnter += &button_mouseEnter;
        button.mouseLeave += &button_mouseLeave;
        button.helpRequested += &button_helpRequested;
        button.gotFocus += &button_gotFocus;
        button.lostFocus += &button_lostFocus;
        button.keyPress += &button_keyPress;
    }

    private void button_keyPress(Object sender, CallbackEventArgs e, int key)
    {
        IupElement element = cast(IupElement)sender;

        if(isPrintable(key))
        {
            writefln("keyPress(%s, %d = %s \'%c\')", element.name, key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("keyPress(%s, %d = %s)", element.name, key, Keys.toName(key));
        }

        writefln("ModifierKeyState(%s)", Keys.getModifierKeyState()); 
    }


    private void button_lostFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("lostFocus(%s)", element.name); 
    }

    private void button_gotFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("gotFocus(%s)", element.name); 
    }

    private void button_helpRequested(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HelpRequested(%s)", element.name); 
    }

    private void okButton_click(Object sender, CallbackEventArgs e)
    {
        IupFlatButton button = cast(IupFlatButton)sender;
        m_isActive = !m_isActive;
        this.child.isAcitve = m_isActive;
        button.enabled = true;
    }
    private bool m_isActive = true;

    private void button_click(Object sender, CallbackEventArgs e)
    {
        IupElement button = cast(IupElement)sender;
        writefln("FLAT_ACTION(%s) - %d", button.name, count); 
        count++;
    }

    private void button_mouseEnter(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseEnter(%s)", element.name); 
    }

    private void button_mouseLeave(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseLeave(%s)", element.name); 
    }



    private int count = 1;

}