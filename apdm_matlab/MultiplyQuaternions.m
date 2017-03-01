function qr = MultiplyQuaternions(q0,q1)
% qr = MultiplyQuaternions(q0,q1)
% Multiplies q0 by q1 and returns the result in qr
% q0 and q1 should both be Nx4 arrays

if numel(q0) == 4 && numel(q1) == 4
%     qr = [q0(1)*q1(1) - dot(q0(2:4), q1(2:4)), q0(1).*q1(2:4)+q0(2:4).*q1(1)+[q0(2)*q1(3)-q0(3)*q1(2),q0(3)*q1(1)-q0(1)*q1(3),q0(1)*q1(2)-q0(2)*q0(1)]];
    qr = zeros(size(q0));
    qr(1) = q0(1)*q1(1) - q0(2)*q1(2) - q0(3)*q1(3) - q0(4)*q1(4);
    qr(2) = q0(1)*q1(2) + q0(2)*q1(1) + q0(3)*q1(4) - q0(4)*q1(3);
    qr(3) = q0(1)*q1(3) - q0(2)*q1(4) + q0(3)*q1(1) + q0(4)*q1(2);
    qr(4) = q0(1)*q1(4) + q0(2)*q1(3) - q0(3)*q1(2) + q0(4)*q1(1);
    return
end

if numel(q0) == 4
    if size(q1, 2) ~= 4
        q1 = q1';
    end
    qr = zeros(size(q1));
    for c1 = 1:size(q1,1)
        qr(c1,1) = q0(1)*q1(c1,1) - q0(2)*q1(c1,2) - q0(3)*q1(c1,3) - q0(4)*q1(c1,4);
        qr(c1,2) = q0(1)*q1(c1,2) + q0(2)*q1(c1,1) + q0(3)*q1(c1,4) - q0(4)*q1(c1,3);
        qr(c1,3) = q0(1)*q1(c1,3) - q0(2)*q1(c1,4) + q0(3)*q1(c1,1) + q0(4)*q1(c1,2);
        qr(c1,4) = q0(1)*q1(c1,4) + q0(2)*q1(c1,3) - q0(3)*q1(c1,2) + q0(4)*q1(c1,1);        
    end
    return
end

if numel(q1) == 4
    if size(q0, 2) ~= 4
        q0 = q0';
    end
    qr = zeros(size(q0));
    for c1 = 1:size(q0,1)
        qr(c1,1) = q0(c1,1)*q1(1) - q0(c1,2)*q1(2) - q0(c1,3)*q1(3) - q0(c1,4)*q1(4);
        qr(c1,2) = q0(c1,1)*q1(2) + q0(c1,2)*q1(1) + q0(c1,3)*q1(4) - q0(c1,4)*q1(3);
        qr(c1,3) = q0(c1,1)*q1(3) - q0(c1,2)*q1(4) + q0(c1,3)*q1(1) + q0(c1,4)*q1(2);
        qr(c1,4) = q0(c1,1)*q1(4) + q0(c1,2)*q1(3) - q0(c1,3)*q1(2) + q0(c1,4)*q1(1);        
    end
    return
end

qt = 0;
if numel(q0) ~= numel(q1)
    error('q0 and q1 must be the same size');
    qr = [];
    return
end

if size(q0,2) ~= 4
    q0 = q0';
end
if size(q1,2) ~= 4
    q1 = q1';
end
qr = zeros(size(q0));
for c1 = 1:size(q0,1)
    qr(c1,1) = q0(c1,1)*q1(c1,1) - q0(c1,2)*q1(c1,2) - q0(c1,3)*q1(c1,3) - q0(c1,4)*q1(c1,4);
    qr(c1,2) = q0(c1,1)*q1(c1,2) + q0(c1,2)*q1(c1,1) + q0(c1,3)*q1(c1,4) - q0(c1,4)*q1(c1,3);
    qr(c1,3) = q0(c1,1)*q1(c1,3) - q0(c1,2)*q1(c1,4) + q0(c1,3)*q1(c1,1) + q0(c1,4)*q1(c1,2);
    qr(c1,4) = q0(c1,1)*q1(c1,4) + q0(c1,2)*q1(c1,3) - q0(c1,3)*q1(c1,2) + q0(c1,4)*q1(c1,1);        
end

