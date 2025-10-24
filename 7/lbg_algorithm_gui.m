function LBG_algorithm_UI_Updated
    % Creating the user interface (UI) for the LBG algorithm
    fig = uifigure('Name', 'LBG Algorithm - Updated', 'Position', [100 100 800 600]);

    % Adding UI components
    lblTitle = uilabel(fig, 'Text', 'LBG Algorithm', 'FontSize', 18, 'Position', [300 550 200 40]);

    % Label to display the running time
    lblRunTime = uilabel(fig, 'Text', 'Running time: 0 s', 'Position', [50 500 200 20]);

    % Input field to define the PDF function
    uilabel(fig, 'Text', 'PDF (to be normalized):', 'Position', [50 460 200 20]);
    pdfInput = uieditfield(fig, 'text', 'Value', 'exp(-(x.^2+y.^2)/2)', 'Position', [200 460 200 20]);

    % Input field to set the resolution
    uilabel(fig, 'Text', 'Resolution:', 'Position', [50 430 200 20]);
    resInput = uieditfield(fig, 'numeric', 'Value', 100, 'Position', [200 430 200 20]);

    % Input field to set the range of data
    uilabel(fig, 'Text', 'Range of (x, y):', 'Position', [50 400 200 20]);
    rangeInput = uieditfield(fig, 'text', 'Value', '-2 2 -2 2', 'Position', [200 400 200 20]);

    % Input field to set the number of quantization points
    uilabel(fig, 'Text', 'Number of quantization points:', 'Position', [50 370 200 20]);
    numQuantPoints = uispinner(fig, 'Value', 7, 'Limits', [1 20], 'Position', [260 370 50 20]);

    % Input field to initialize the seed value
    uilabel(fig, 'Text', 'Seed:', 'Position', [50 340 200 20]);
    seedInput = uieditfield(fig, 'numeric', 'Value', 0, 'Position', [200 340 200 20]);

    % Input field to set the number of optimization iterations
    uilabel(fig, 'Text', 'Global optimization iterations:', 'Position', [50 310 200 20]);
    globalIterInput = uieditfield(fig, 'numeric', 'Value', 10, 'Position', [260 310 50 20]);

    % Adding charts to display results
    ax1 = uiaxes(fig, 'Position', [450 350 300 200]);
    title(ax1, 'Minimum Distortion vs Trial Number');
    xlabel(ax1, 'Trial Number');
    ylabel(ax1, 'Distortion');

    ax2 = uiaxes(fig, 'Position', [450 50 300 200]);
    title(ax2, 'Optimum Quantization Points');
    xlabel(ax2, 'X');
    ylabel(ax2, 'Y');

    % Optimum distortion display
    lblOptDist = uilabel(fig, 'Text', 'Optimum distortion: N/A', 'Position', [50 280 300 20]);

    % Exit button
    btnExit = uibutton(fig, 'push', 'Text', 'EXIT', 'Position', [50 50 100 30], ...
        'ButtonPushedFcn', @(btn, event) close(fig));

    % Run algorithm button
    btnRun = uibutton(fig, 'push', 'Text', 'Run Algorithm', 'Position', [50 100 100 30], ...
        'ButtonPushedFcn', @(btn, event) runAlgorithm());

    % Algorithm function
    function runAlgorithm()
        tic; % Start timing
        % Inputs
        pdfFunc = str2func(['@(x,y)', pdfInput.Value]); % Define the PDF function
        res = resInput.Value;% Get the resolution value
        range = str2num(rangeInput.Value); % Define the range for x and y
        numPoints = numQuantPoints.Value; % Set the number of quantization points
        seed = seedInput.Value; % Set the initial seed value
        globalIter = globalIterInput.Value; % Set the number of iterations

        % Generate data and calculate distortion
        rng(seed); % Set random seed
        [distortion, quantPoints] = LBG_algorithm(pdfFunc, res, range, numPoints, globalIter);

        % Update runtime
        runTime = toc;
        lblRunTime.Text = sprintf('Running time: %.5f s', runTime);

        % Update charts
        plot(ax1, 1:globalIter, distortion, '-o');
        scatter(ax2, quantPoints(:, 1), quantPoints(:, 2), 'x');

        % Update optimum distortion
        lblOptDist.Text = sprintf('Optimum distortion (%d trials) = %.6f', globalIter, min(distortion));
    end

    % LBG algorithm function
    function [distortion, quantPoints] = LBG_algorithm(pdf, res, range, numPoints, globalIter)
        % Defining the range for x and y
        x0 = range(1);
        xN = range(2);
        y0 = range(3);
        yN = range(4);
        
        % Creating a grid of points in the specified range
        x = x0 + (0:res-1) * (xN - x0) / (res-1);
        y = y0 + (0:res-1) * (yN - y0) / (res-1);
        
        [X, Y] = meshgrid(x, y);
        % Calculate and normalize the PDF
        P = pdf(X, Y); % Calculate PDF values
        P = P / sum(P(:)); % Normalize PDF

        % Variables for the best quantized points and the minimum distortion
        min_distortion = inf;
        bestQuantPoints = [];
        distortion = zeros(1, globalIter);
        % Random initialization for each trial
            quantPoints = [rand(numPoints, 1) * (range(2) - range(1)) + range(1), ...
                           rand(numPoints, 1) * (range(4) - range(3)) + range(3)];
            prev_distortion = inf; % Initial value of Distortion
        for trial = 1:globalIter
            
            
            for iter = 1:100 % Maximum iterations per trial
                % Compute distances and assignments
                distances = pdist2([X(:), Y(:)], quantPoints);
                [~, idx] = min(distances, [], 2);
                
                % Update quantization points
                for k = 1:numPoints
                    mask = idx == k; % Selecting the points that have been assigned to this center
                    if sum(mask) > 0
                        quantPoints(k, :) = [sum(X(mask) .* P(mask)) / sum(P(mask)), ...
                                             sum(Y(mask) .* P(mask)) / sum(P(mask))];
                    end
                end
                current_distortion = sum(P(:) .* min(distances, [], 2).^2);
                if abs(prev_distortion - current_distortion) < 1e-5
                    break; % If the changes are negligible, the algorithm stops
                end
                prev_distortion = current_distortion;
            end
            % Calculate distortion and best points in each trial
            distortion(trial) = current_distortion;
            if current_distortion < min_distortion
                min_distortion = current_distortion;
                bestQuantPoints = quantPoints;
            end
        end
        quantPoints = bestQuantPoints; % Return the best points
    end
end
