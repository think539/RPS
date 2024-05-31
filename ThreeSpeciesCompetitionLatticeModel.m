clc; clear;
%초기값
sigma = 1; mu = 1; epsilon = 3/8; N=500;

%초기 종 행렬(4:빈 공간,1:바위,2:가위,3:보)
values = [repmat(1, 1, N*N/4), repmat(2, 1, N*N/4), repmat(3, 1, N*N/4), repmat(4, 1, N*N/4)];
shuffledValues = values(randperm(length(values)));
matrix = reshape(shuffledValues, N, N);

% 비디오를 저장할 Figure 생성
fig = figure;
% 프레임을 저장할 구조체 배열 초기화
numFrames=50000;
frames(numFrames) = struct('cdata', [], 'colormap', []);
    
for k = 1:numFrames
    %game 실행
    matrix = game(matrix,N);
    % 행렬을 이미지로 표시
    imagesc(matrix);
        
    % 컬러맵 정의: 1은 빨간색, 2는 파란색, 3은 초록색 4는 검정색
    colormap([1 0 0; 0 0 1; 0 1 0;0 0 0]);
        
    % 컬러바 추가 및 축 설정
    colorbar('Ticks', [1, 2, 3, 4], 'TickLabels', {'1 (Red)', '2 (Blue)', '3 (Green)', '4 (Black)'});
    axis equal tight;
        
    % 제목 추가
    title(['Frame: ', num2str(k)]);
        
    % 프레임 저장
    frames(k) = getframe(fig);
        
    % 잠시 멈춤 (애니메이션 속도를 제어)
    %pause(0.001);
end
    
% 비디오 파일로 애니메이션 저장
videoFilename = 'mobility5_500_120.avi';
v = VideoWriter(videoFilename);
v.FrameRate = 240; % 프레임 속도를 설정 (30 FPS)

open(v);
for k = 1:numFrames
    writeVideo(v, frames(k));
end
close(v);

% Figure 닫기
close(fig);

% 저장된 비디오 파일을 확인하려면 다음 명령을 사용:
% implay(videoFilename);

%함수 정의
function result=game(m,N)
    result = m;
    for i = 1:N*N
        row = randi([1, N]);
        col = randi([1, N]);
        if m(row,col) ~= 4
            li=sites(row,col,N);
            active = li(randi([1, 4]),:);
            num=0;
            while num == 0
                act = randomAct(1,1,125);
                if act == 's'
                    result(active(1),active(2)) = selection(result(row,col),result(active(1),active(2)));
                    num=1;
                elseif act == 'r'
                    if m(active(1),active(2)) == 4
                        result(active(1),active(2)) = result(row,col);
                    end
                    num=1;
                elseif act == 'e'
                    a = result(active(1),active(2));
                    b = result(row,col);
                    result(row,col) = a;
                    result(active(1),active(2)) = b;
                    num=1;
                end
                if num == 0
                    temp1=row;
                    row = active(1); active(1) = temp1;
                    temp2=col;
                    col = active(2); active(2) = temp2;
                end
            end
        end
    end
end

function result = randomAct(sigma,mu,epsilon)
    % 0과 1 사이의 난수를 생성
    randValue = rand;

    % 각 문자에 해당하는 확률
    p = 1 / (sigma+mu+epsilon);

    % 확률에 따라 문자를 선택
    if randValue < p
        result = 's';
    elseif randValue < 2*p
        result = 'r';
    else
        result = 'e';
    end
end

%동서남북 sites
function result = sites(row,col,N)
    if row == 1
        if col == 1
            result = [[1,2];[1,N];[2,1];[N,1]];
        elseif col == N
            result = [[1,1];[1,N-1];[2,N];[N,N]];
        else
            result = [[1,col+1];[1,col-1];[2,col];[N,col]];
        end
    elseif row == N
        if col == 1
            result = [[N,2];[N,N];[1,1];[N-1,1]];
        elseif col == N
            result = [[N,1];[N,N-1];[1,N];[N-1,N]];
        else
            result = [[N,col+1];[N,col-1];[1,col];[N-1,col]];
        end
    else
        if col == 1
            result = [[row,col+1];[row,N];[row+1,1];[row-1,1]];
        elseif col == N
            result = [[row,1];[row,N-1];[row-1,N];[row+1,N]];
        else
            result = [[row,col+1];[row,col-1];[row+1,col];[row-1,col]];
        end
    end
end

function result=selection(a,b)
    result=b;
    if (a==1)&&(b==2) 
        result = 4;
    elseif (a==2)&&(b==3)
        result = 4;
    elseif (a==3)&&(b==1)
        result = 4;
    end
end
