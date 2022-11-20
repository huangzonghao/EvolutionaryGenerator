% Adapted from https://blogs.mathworks.com/graphics/2015/07/01/stacked-bar3/
function h = stacked_bar3(target_ax, array)
    if any(array(:) < 0)
        error('Only positive values supported')
    end

    dims = size(array);
    if any(dims==0)
        error('Empty dimensions are not supported')
    end

    switch length(dims)
        case 2
            ns = 1;
        case 3
            ns = dims(3);
        otherwise
            error('Must be a 3D array')
    end
    nr = dims(1);
    nc = dims(2);

    % ax = newplot; % plot to the most recent figure -- this is automatically called in plot()
    ax = newplot(target_ax);
    co = ax.ColorOrder;
    h = gobjects(1, ns+1); % matrix of graph objects

    % TODO: first plot the white ground -- replace with the code at the bottom of this file

    view(ax, 3)
    % nc is x, nr is y
    xlim(ax, [.5, nc+.5]) % so that the int will show up at the center of the bin
    ylim(ax, [.5, nr+.5])

    bw = 0.5;
    offmat = [-bw, +bw, 0; ...
              -bw, -bw, 0; ...
              +bw, -bw, 0; ...
              +bw, +bw, 0];
    sidemat = [1, 2, 2, 1; ...
               2, 3, 3, 2; ...
               3, 4, 4, 3; ...
               4, 1, 1, 4] ...
               + repmat([0, 0, 4*nr*nc, 4*nr*nc],[4, 1]);
    topmat = (1:4) + 4*nr*nc;

    top = zeros(dims(1:2));
    for s = 1 : ns
        if sum(array(:,:,s), 'all') == 0
            continue
        end

        bottom = top;
        top = bottom + array(:,:,s);

        verts = zeros(4*nr*nc*2, 3);
        faces = ones(5*nr*nc, 4);
        for r = 1 : nr
            for c = 1 : nc
                vindex = 4*(r-1+nr*(c-1));
                lindex = 5*(r-1+nr*(c-1));
                rindex = 4*(r-1+nr*(c-1));
                verts(vindex+(1:4)', :) = repmat([c,r,bottom(r,c)],[4,1]) + offmat;
                verts(vindex+4*nr*nc+(1:4)', :) = repmat([c, r, top(r,c)], [4,1]) + offmat;
                if array(r,c,s) > 0
                    faces(lindex+(1:5)',:) = rindex + [sidemat; topmat];
                end
            end
        end

        cix = 1 + mod(s - 1, size(co,1));
        h(s) = patch('Vertices', verts, ...
                     'Faces', faces, ...
                     'FaceColor', co(cix,:), ...
                     'Parent', ax);

    end

    % Attach the final layer to white out the zero bins
    % patch: each polygon is a vector (column)
    % TODO: vectorize the following code
    patch_x = [];
    patch_y = [];
    for r = 1 : nr
        for c = 1: nc
            if top(r, c) == 0
                patch_x(:, end+1) = ones(4,1) * c + offmat(:, 1);
                patch_y(:, end+1) = ones(4,1) * r + offmat(:, 2);
            end
        end
    end
    h(ns+1) = patch(patch_x, patch_y, zeros(size(patch_x)), 'white', 'Parent', ax);

    zlim(ax, [0, max(1, max(top(:)))]);
end
