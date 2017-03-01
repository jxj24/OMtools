function vr = RotateVector(v,q)

if numel(q) == 4 && numel(v) == 3
    vr = MultiplyQuaternions(q,[0, v]);
    vr = MultiplyQuaternions(vr, [q(1) -q(2:4)]);
    vr = vr(2:4);
else
    vr = MultiplyQuaternions(q, [zeros(size(v,1),1), v]);
    vr = MultiplyQuaternions(vr, [q(:,1) -q(:,2:4)]);
    vr = vr(:,2:4);
end

end

% % Todo: Rewrite above to use this optimized algorithm. Should be about
% % half the operations.
% function vr = RotateVectorCheck(v,q)
%     x1 = q(3)*v(3) - q(4)*v(2);
%     y1 = q(4)*v(1) - q(2)*v(3);
%     z1 = q(2)*v(2) - q(3)*v(1);
% 
%     x2 = q(1)*x1 + q(3)*z1 - q(4)*y1;
%     y2 = q(1)*y1 + q(4)*x1 - q(2)*z1;
%     z2 = q(1)*z1 + q(2)*y1 - q(3)*x1;
%     
%     vr = [v(1) + 2*x2, v(2) + 2*y2, v(3) + 2*z2];
% end