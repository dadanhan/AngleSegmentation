%function that segments tracks from Polyparticle Tracker given a threshold
%angle and threshold distance.
%Daniel Han Nov 2017
%INPUT: 
%>>>>>>>>>pTrk an array with format (x,y,t) in time order series.
%>>>>>>>>>thres_angle is the threshold angle in degrees either side of the particle 
%track in which to consider the next track. E.g. thres_angle = 45 actually
%means a 90 degree field of view from the particle track perspective.
%>>>>>>>>>thres_distance is the distance in which to consider a track.
%Below this distance, the track is considered to be noise.
%>>>>>>>>>lengthScale is the scale of distance per pixel in the movie
%>>>>>>>>>timeScale is the number of seconds per frame in the movie

function [TrackHistogram,TimeHistogram,VelHistogram] = TurnFilterFunc(pTrk,thres_angle,thres_dist,lengthScale,timeScale,TrackHistogram,TimeHistogram,VelHistogram)
%convert this to radians
thres_angle = ((pi)/(180))*thres_angle;
%declare variable to store track path and times
pathNew = [pTrk(1,1),pTrk(1,2)];
timeNew = [pTrk(1,3)];
%create counter for index
pdex = 1;
%loop through elements in pTrk and store the points in pTrk
%that are within threshold angle into pathNew
while pdex <= length(pTrk)-2
    tempdist = lengthScale*sqrt( (pTrk(pdex+1,1)-pTrk(pdex,1))^2 + (pTrk(pdex+1,2)-pTrk(pdex,2))^2 );
    %find the angles that the paths make
    angle = acos(( (pTrk(pdex+1,1)-pTrk(pdex,1))*(pTrk(pdex+2,1)-pTrk(pdex+1,1))+(pTrk(pdex+1,2)-pTrk(pdex,2))*(pTrk(pdex+2,2)-pTrk(pdex+1,2)) )/( sqrt( (pTrk(pdex+1,1)-pTrk(pdex,1))^2 + (pTrk(pdex+1,2)-pTrk(pdex,2))^2 )*sqrt( (pTrk(pdex+2,1)-pTrk(pdex+1,1))^2 + (pTrk(pdex+2,2)-pTrk(pdex+1,2))^2 ) ));
    %disp(angle*(180)/(pi));
    %filtering out the tracks which make an angle below the threshold
    %angle to the step previous to this step
    if tempdist > thres_dist
        if pdex == length(pTrk)-2
            if angle < thres_angle
                pathNew = [pathNew; pTrk(pdex+2,1),pTrk(pdex+2,2)];
                timeNew = [timeNew; pTrk(pdex+2,3)];
                pdex = pdex+2;
            else
                pathNew = [pathNew; pTrk(pdex+1,1),pTrk(pdex+1,2)];
                timeNew = [timeNew; pTrk(pdex+1,3)];
                pathNew = [pathNew; pTrk(pdex+2,1),pTrk(pdex+2,2)];
                timeNew = [timeNew; pTrk(pdex+2,3)];
                pdex = pdex+2;
            end
        else
            if angle < thres_angle
                pdex = pdex+1;
            else
                pathNew = [pathNew; pTrk(pdex+1,1),pTrk(pdex+1,2)];
                timeNew = [timeNew; pTrk(pdex+1,3)];
                pdex = pdex+1;
            end
        end
    else
        pdex = pdex+1;
    end
end
%store the displacements and the run times into hist data
if length(pathNew) > 2
    displacements = 1e6*lengthScale*( (pathNew(2:length(pathNew),1)-pathNew(1:(length(pathNew)-1),1)).^2 + (pathNew(2:length(pathNew),2)-pathNew(1:(length(pathNew)-1),2)).^2 ).^(0.5);
else
    displacements = 0;
end
times = timeScale*(timeNew(2:length(timeNew))-timeNew(1:(length(timeNew)-1)));
velocities = displacements./times;
TrackHistogram = [TrackHistogram; displacements(2:length(displacements)-1)];
TimeHistogram = [TimeHistogram; times(2:length(times)-1)];
VelHistogram = [VelHistogram; velocities(2:length(velocities)-1)];
end